<?php
/**
 * API: CRUD Operations for Gene Records
 * Endpoints:
 *   POST   ?action=create   - Create a new gene record
 *   PUT    ?action=update   - Update existing gene record
 *   DELETE ?action=delete   - Delete gene record
 *   POST   ?action=update_expression  - Update expression data for a gene
 */

require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$pdo    = getDBConnection();
$action = $_GET['action'] ?? $_POST['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

// Read JSON body
$inputJSON = json_decode(file_get_contents('php://input'), true) ?? [];
// Merge with POST data
$input = array_merge($_POST, $inputJSON);

switch ($action) {

    // ── CREATE a new gene ─────────────────────────────────────────────
    case 'create': {
        if ($method !== 'POST') {
            sendJSON(['error' => 'POST method required'], 405);
        }

        $required = ['gene_symbol', 'gene_name', 'chromosome'];
        foreach ($required as $field) {
            if (empty(trim($input[$field] ?? ''))) {
                sendJSON(['error' => "Field '$field' is required"], 400);
            }
        }

        $symbol = strtoupper(trim($input['gene_symbol']));

        // Check uniqueness
        $check = $pdo->prepare("SELECT gene_id FROM genes WHERE gene_symbol = :sym");
        $check->execute([':sym' => $symbol]);
        if ($check->fetch()) {
            sendJSON(['error' => "Gene symbol '$symbol' already exists"], 409);
        }

        $stmt = $pdo->prepare(
            "INSERT INTO genes
               (gene_symbol, gene_name, chromosome, start_pos, end_pos, strand,
                description, gene_type, ncbi_id, ensembl_id)
             VALUES
               (:sym, :name, :chr, :start, :end, :strand,
                :desc, :type, :ncbi, :ensembl)"
        );
        $stmt->execute([
            ':sym'    => $symbol,
            ':name'   => trim($input['gene_name']),
            ':chr'    => trim($input['chromosome']),
            ':start'  => !empty($input['start_pos'])  ? (int)$input['start_pos']  : null,
            ':end'    => !empty($input['end_pos'])     ? (int)$input['end_pos']    : null,
            ':strand' => $input['strand'] ?? null,
            ':desc'   => $input['description'] ?? null,
            ':type'   => $input['gene_type']   ?? 'protein_coding',
            ':ncbi'   => $input['ncbi_id']     ?? null,
            ':ensembl'=> $input['ensembl_id']  ?? null,
        ]);

        $newId = (int)$pdo->lastInsertId();

        // Optionally add expression data
        if (isset($input['normal_expression']) && isset($input['cancer_expression'])) {
            $norm  = (float)$input['normal_expression'];
            $canc  = (float)$input['cancer_expression'];
            $l2fc  = ($norm > 0) ? log($canc / $norm) / log(2) : 0;
            $pval  = isset($input['p_value']) ? (float)$input['p_value'] : 0.05;
            $reg   = ($l2fc > 1) ? 'up' : (($l2fc < -1) ? 'down' : 'unchanged');
            $sig   = ($pval < 0.05) ? 1 : 0;

            $eStmt = $pdo->prepare(
                "INSERT INTO expression_data
                   (gene_id, tissue_type, normal_expression, cancer_expression,
                    fold_change, log2_fold_change, p_value, adj_p_value,
                    is_significant, regulation)
                 VALUES
                   (:gid, 'breast', :norm, :canc, :fc, :l2fc, :pval,
                    :adjp, :sig, :reg)"
            );
            $eStmt->execute([
                ':gid'  => $newId,
                ':norm' => $norm,
                ':canc' => $canc,
                ':fc'   => ($norm > 0) ? $canc / $norm : null,
                ':l2fc' => $l2fc,
                ':pval' => $pval,
                ':adjp' => min($pval * 1.5, 1.0),
                ':sig'  => $sig,
                ':reg'  => $reg,
            ]);
        }

        sendJSON(['success' => true, 'gene_id' => $newId, 'message' => "Gene $symbol created successfully"], 201);
        break;
    }

    // ── UPDATE an existing gene ───────────────────────────────────────
    case 'update': {
        if (!in_array($method, ['POST', 'PUT'])) {
            sendJSON(['error' => 'POST or PUT method required'], 405);
        }

        $id = (int)($input['gene_id'] ?? 0);
        if ($id <= 0) {
            sendJSON(['error' => '"gene_id" is required for update'], 400);
        }

        // Check existence
        $check = $pdo->prepare("SELECT gene_id FROM genes WHERE gene_id = :id");
        $check->execute([':id' => $id]);
        if (!$check->fetch()) {
            sendJSON(['error' => "Gene with id=$id not found"], 404);
        }

        $fields = [];
        $params = [':id' => $id];
        $allowed = ['gene_symbol','gene_name','chromosome','start_pos','end_pos',
                    'strand','description','gene_type','ncbi_id','ensembl_id'];
        foreach ($allowed as $f) {
            if (array_key_exists($f, $input)) {
                $fields[] = "$f = :$f";
                $params[":$f"] = ($f === 'gene_symbol') ? strtoupper(trim($input[$f])) : $input[$f];
            }
        }

        if (!empty($fields)) {
            $sql  = "UPDATE genes SET " . implode(', ', $fields) . " WHERE gene_id = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
        }

        sendJSON(['success' => true, 'message' => "Gene id=$id updated successfully"]);
        break;
    }

    // ── DELETE a gene ─────────────────────────────────────────────────
    case 'delete': {
        if (!in_array($method, ['POST', 'DELETE'])) {
            sendJSON(['error' => 'POST or DELETE method required'], 405);
        }

        $id = (int)($input['gene_id'] ?? $_GET['gene_id'] ?? 0);
        if ($id <= 0) {
            sendJSON(['error' => '"gene_id" is required for deletion'], 400);
        }

        // Check existence
        $check = $pdo->prepare("SELECT gene_symbol FROM genes WHERE gene_id = :id");
        $check->execute([':id' => $id]);
        $gene = $check->fetch();
        if (!$gene) {
            sendJSON(['error' => "Gene with id=$id not found"], 404);
        }

        // ON DELETE CASCADE will remove expression_data and blast_sequences
        $stmt = $pdo->prepare("DELETE FROM genes WHERE gene_id = :id");
        $stmt->execute([':id' => $id]);

        sendJSON(['success' => true, 'message' => "Gene {$gene['gene_symbol']} (id=$id) deleted"]);
        break;
    }

    // ── UPDATE expression data for a gene ─────────────────────────────
    case 'update_expression': {
        if (!in_array($method, ['POST', 'PUT'])) {
            sendJSON(['error' => 'POST or PUT method required'], 405);
        }

        $geneId = (int)($input['gene_id'] ?? 0);
        $symbol = strtoupper(trim($input['gene_symbol'] ?? ''));

        if ($geneId <= 0 && $symbol === '') {
            sendJSON(['error' => 'Provide "gene_id" or "gene_symbol"'], 400);
        }

        // Resolve gene_id from symbol if needed
        if ($geneId <= 0) {
            $g = $pdo->prepare("SELECT gene_id FROM genes WHERE gene_symbol = :sym");
            $g->execute([':sym' => $symbol]);
            $row = $g->fetch();
            if (!$row) {
                sendJSON(['error' => "Gene '$symbol' not found"], 404);
            }
            $geneId = (int)$row['gene_id'];
        }

        $norm = (float)($input['normal_expression'] ?? 0);
        $canc = (float)($input['cancer_expression'] ?? 0);
        $pval = isset($input['p_value']) ? (float)$input['p_value'] : null;

        if ($norm <= 0 || $canc < 0) {
            sendJSON(['error' => 'Valid expression values required'], 400);
        }

        $l2fc = ($norm > 0 && $canc > 0) ? log($canc / $norm) / log(2) : 0;
        $fc   = ($norm > 0) ? $canc / $norm : null;
        $reg  = ($l2fc > 1) ? 'up' : (($l2fc < -1) ? 'down' : 'unchanged');
        $sig  = ($pval !== null && $pval < 0.05) ? 1 : 0;

        // Upsert
        $exists = $pdo->prepare("SELECT expr_id FROM expression_data WHERE gene_id = :id");
        $exists->execute([':id' => $geneId]);

        if ($exists->fetch()) {
            $fields = [
                "normal_expression = :norm",
                "cancer_expression = :canc",
                "fold_change = :fc",
                "log2_fold_change = :l2fc",
                "regulation = :reg",
            ];
            $params = [
                ':id'   => $geneId,
                ':norm' => $norm,
                ':canc' => $canc,
                ':fc'   => $fc,
                ':l2fc' => $l2fc,
                ':reg'  => $reg,
            ];
            if ($pval !== null) {
                $fields[] = "p_value = :pval";
                $fields[] = "adj_p_value = :adjp";
                $fields[] = "is_significant = :sig";
                $params[':pval'] = $pval;
                $params[':adjp'] = min($pval * 1.5, 1.0);
                $params[':sig']  = $sig;
            }
            $stmt = $pdo->prepare(
                "UPDATE expression_data SET " . implode(', ', $fields) . " WHERE gene_id = :id"
            );
            $stmt->execute($params);
        } else {
            $stmt = $pdo->prepare(
                "INSERT INTO expression_data
                   (gene_id, tissue_type, normal_expression, cancer_expression,
                    fold_change, log2_fold_change, p_value, adj_p_value,
                    is_significant, regulation)
                 VALUES
                   (:id, 'breast', :norm, :canc, :fc, :l2fc, :pval, :adjp, :sig, :reg)"
            );
            $stmt->execute([
                ':id'   => $geneId,
                ':norm' => $norm,
                ':canc' => $canc,
                ':fc'   => $fc,
                ':l2fc' => $l2fc,
                ':pval' => $pval,
                ':adjp' => ($pval !== null) ? min($pval * 1.5, 1.0) : null,
                ':sig'  => $sig,
                ':reg'  => $reg,
            ]);
        }

        sendJSON(['success' => true, 'message' => "Expression data updated for gene_id=$geneId"]);
        break;
    }

    default:
        sendJSON(['error' => 'Unknown action. Valid: create, update, delete, update_expression'], 400);
}
