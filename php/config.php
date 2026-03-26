<?php
/**
 * Database Configuration
 * Breast Cancer RNA-seq Analysis Platform
 * Modify HOST, USER, PASS, DB to match your XAMPP setup
 */

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');          // default XAMPP root password is empty
define('DB_NAME', 'breast_cancer_rna_seq');
define('DB_CHARSET', 'utf8mb4');

/**
 * Create a PDO database connection
 */
function getDBConnection(): PDO {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    try {
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
        exit;
    }
}

/**
 * Send a JSON response with appropriate headers
 */
function sendJSON($data, int $statusCode = 200): void {
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * Get database statistics
 */
function getStats(PDO $pdo): array {
    $stats = [];

    $row = $pdo->query("SELECT COUNT(*) AS cnt FROM genes")->fetch();
    $stats['total_genes'] = (int)$row['cnt'];

    $row = $pdo->query("SELECT COUNT(*) AS cnt FROM expression_data")->fetch();
    $stats['total_expression_records'] = (int)$row['cnt'];

    $row = $pdo->query("SELECT COUNT(*) AS cnt FROM blast_sequences")->fetch();
    $stats['blast_sequences'] = (int)$row['cnt'];

    $row = $pdo->query("SELECT COUNT(*) AS cnt FROM samples")->fetch();
    $stats['total_samples'] = (int)$row['cnt'];

    $row = $pdo->query(
        "SELECT COUNT(*) AS cnt FROM expression_data WHERE is_significant=1 AND regulation='up'"
    )->fetch();
    $stats['up_regulated'] = (int)$row['cnt'];

    $row = $pdo->query(
        "SELECT COUNT(*) AS cnt FROM expression_data WHERE is_significant=1 AND regulation='down'"
    )->fetch();
    $stats['down_regulated'] = (int)$row['cnt'];

    $stats['species'] = ['Homo sapiens'];
    $stats['data_source'] = 'Simulated RNA-seq data (TCGA breast cancer format)';

    return $stats;
}
