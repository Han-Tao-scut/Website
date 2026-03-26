<?php
/**
 * API: Gene Query
 * Endpoints:
 *   GET  ?action=search&q=TP53            - search by name/symbol
 *   GET  ?action=get&id=1                 - get single gene by ID
 *   GET  ?action=list&page=1&limit=20     - paginated list of all genes
 *   GET  ?action=stats                    - database statistics
 */

require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$pdo    = getDBConnection();
$action = $_GET['action'] ?? 'list';

switch ($action) {

    // ── Search genes by keyword ────────────────────────────────────────
    case 'search': {
        $q = trim($_GET['q'] ?? '');
        if ($q === '') {
            sendJSON(['error' => 'Query parameter "q" is required'], 400);
        }
        $like = '%' . $q . '%';
        $stmt = $pdo->prepare(
            "SELECT g.gene_id, g.gene_symbol, g.gene_name, g.chromosome,
                    g.description, g.gene_type, g.ncbi_id, g.ensembl_id,
                    e.normal_expression, e.cancer_expression,
                    e.log2_fold_change, e.p_value, e.regulation, e.is_significant
             FROM genes g
             LEFT JOIN expression_data e ON g.gene_id = e.gene_id
             WHERE g.gene_symbol LIKE :q1
                OR g.gene_name   LIKE :q2
                OR g.ncbi_id     LIKE :q3
             ORDER BY
               CASE WHEN g.gene_symbol = :exact THEN 0 ELSE 1 END,
               g.gene_symbol
             LIMIT 50"
        );
        $stmt->execute([':q1' => $like, ':q2' => $like, ':q3' => $like, ':exact' => strtoupper($q)]);
        $results = $stmt->fetchAll();
        sendJSON(['query' => $q, 'count' => count($results), 'results' => $results]);
        break;
    }

    // ── Get single gene by ID ──────────────────────────────────────────
    case 'get': {
        $id = (int)($_GET['id'] ?? 0);
        if ($id <= 0) {
            sendJSON(['error' => 'Valid "id" parameter is required'], 400);
        }
        $stmt = $pdo->prepare(
            "SELECT g.*, e.normal_expression, e.cancer_expression,
                    e.fold_change, e.log2_fold_change, e.p_value, e.adj_p_value,
                    e.regulation, e.is_significant
             FROM genes g
             LEFT JOIN expression_data e ON g.gene_id = e.gene_id
             WHERE g.gene_id = :id"
        );
        $stmt->execute([':id' => $id]);
        $gene = $stmt->fetch();
        if (!$gene) {
            sendJSON(['error' => "Gene with id=$id not found"], 404);
        }
        sendJSON($gene);
        break;
    }

    // ── Paginated list of all genes ───────────────────────────────────
    case 'list': {
        $page  = max(1, (int)($_GET['page']  ?? 1));
        $limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
        $offset = ($page - 1) * $limit;

        $total = (int)$pdo->query("SELECT COUNT(*) FROM genes")->fetchColumn();

        $stmt = $pdo->prepare(
            "SELECT g.gene_id, g.gene_symbol, g.gene_name, g.chromosome,
                    g.description, g.gene_type,
                    e.normal_expression, e.cancer_expression,
                    e.log2_fold_change, e.p_value, e.regulation, e.is_significant
             FROM genes g
             LEFT JOIN expression_data e ON g.gene_id = e.gene_id
             ORDER BY g.gene_symbol
             LIMIT :lim OFFSET :off"
        );
        $stmt->bindValue(':lim', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':off', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $genes = $stmt->fetchAll();

        sendJSON([
            'page'       => $page,
            'limit'      => $limit,
            'total'      => $total,
            'pages'      => (int)ceil($total / $limit),
            'genes'      => $genes,
        ]);
        break;
    }

    // ── Database statistics ────────────────────────────────────────────
    case 'stats': {
        sendJSON(getStats($pdo));
        break;
    }

    default:
        sendJSON(['error' => 'Unknown action'], 400);
}
