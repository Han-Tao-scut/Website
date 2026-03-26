<?php
/**
 * API: Expression Data
 * Endpoints:
 *   GET  ?action=get_by_gene&gene_id=1           - expression for one gene
 *   GET  ?action=top_degs&n=20&regulation=up     - top differentially expressed genes
 *   GET  ?action=volcano                          - data for volcano plot (all genes)
 *   GET  ?action=heatmap&symbols=TP53,BRCA1,...   - expression for selected genes
 */

require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$pdo    = getDBConnection();
$action = $_GET['action'] ?? 'get_by_gene';

switch ($action) {

    // ── Expression for a single gene ──────────────────────────────────
    case 'get_by_gene': {
        $geneId = (int)($_GET['gene_id'] ?? 0);
        $symbol = trim($_GET['symbol'] ?? '');

        if ($geneId <= 0 && $symbol === '') {
            sendJSON(['error' => 'Provide "gene_id" or "symbol"'], 400);
        }

        if ($symbol !== '') {
            $stmt = $pdo->prepare(
                "SELECT e.*, g.gene_symbol, g.gene_name
                 FROM expression_data e
                 JOIN genes g ON e.gene_id = g.gene_id
                 WHERE g.gene_symbol = :sym"
            );
            $stmt->execute([':sym' => strtoupper($symbol)]);
        } else {
            $stmt = $pdo->prepare(
                "SELECT e.*, g.gene_symbol, g.gene_name
                 FROM expression_data e
                 JOIN genes g ON e.gene_id = g.gene_id
                 WHERE e.gene_id = :id"
            );
            $stmt->execute([':id' => $geneId]);
        }

        $data = $stmt->fetch();
        if (!$data) {
            sendJSON(['error' => 'Expression data not found'], 404);
        }
        sendJSON($data);
        break;
    }

    // ── Top differentially expressed genes ───────────────────────────
    case 'top_degs': {
        $n          = min(100, max(1, (int)($_GET['n'] ?? 20)));
        $regulation = $_GET['regulation'] ?? 'all';   // 'up', 'down', or 'all'

        $where = "WHERE e.is_significant = 1";
        if (in_array($regulation, ['up', 'down'])) {
            $where .= " AND e.regulation = " . $pdo->quote($regulation);
        }

        $stmt = $pdo->prepare(
            "SELECT g.gene_symbol, g.gene_name, g.chromosome,
                    e.normal_expression, e.cancer_expression,
                    e.log2_fold_change, e.p_value, e.adj_p_value,
                    e.regulation, e.is_significant
             FROM expression_data e
             JOIN genes g ON e.gene_id = g.gene_id
             $where
             ORDER BY ABS(e.log2_fold_change) DESC
             LIMIT :n"
        );
        $stmt->bindValue(':n', $n, PDO::PARAM_INT);
        $stmt->execute();
        $degs = $stmt->fetchAll();

        sendJSON(['count' => count($degs), 'genes' => $degs]);
        break;
    }

    // ── Volcano plot data (all genes) ─────────────────────────────────
    case 'volcano': {
        $stmt = $pdo->query(
            "SELECT g.gene_symbol, e.log2_fold_change,
                    -LOG10(e.p_value) AS neg_log10_pvalue,
                    e.p_value, e.adj_p_value,
                    e.regulation, e.is_significant
             FROM expression_data e
             JOIN genes g ON e.gene_id = g.gene_id
             WHERE e.p_value > 0
             ORDER BY g.gene_symbol"
        );
        $data = $stmt->fetchAll();
        sendJSON(['count' => count($data), 'data' => $data]);
        break;
    }

    // ── Heatmap data for selected genes ──────────────────────────────
    case 'heatmap': {
        $rawSymbols = trim($_GET['symbols'] ?? '');
        if ($rawSymbols === '') {
            // Return top 30 DEGs by default
            $stmt = $pdo->query(
                "SELECT g.gene_symbol, e.normal_expression, e.cancer_expression,
                        e.log2_fold_change, e.regulation
                 FROM expression_data e
                 JOIN genes g ON e.gene_id = g.gene_id
                 WHERE e.is_significant = 1
                 ORDER BY ABS(e.log2_fold_change) DESC
                 LIMIT 30"
            );
        } else {
            $symbols = array_map('strtoupper', array_map('trim', explode(',', $rawSymbols)));
            $symbols = array_filter($symbols); // remove empty
            if (empty($symbols)) {
                sendJSON(['error' => 'No valid symbols provided'], 400);
            }
            // Build parameterized IN clause
            $placeholders = implode(',', array_fill(0, count($symbols), '?'));
            $stmt = $pdo->prepare(
                "SELECT g.gene_symbol, e.normal_expression, e.cancer_expression,
                        e.log2_fold_change, e.regulation
                 FROM expression_data e
                 JOIN genes g ON e.gene_id = g.gene_id
                 WHERE g.gene_symbol IN ($placeholders)
                 ORDER BY e.log2_fold_change DESC"
            );
            $stmt->execute($symbols);
        }
        $data = $stmt->fetchAll();
        sendJSON(['count' => count($data), 'data' => $data]);
        break;
    }

    default:
        sendJSON(['error' => 'Unknown action'], 400);
}
