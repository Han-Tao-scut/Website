<?php
/**
 * API: BLAST-like Sequence Search
 * Uses simple local alignment (substring matching + similarity scoring)
 * Endpoints:
 *   POST ?action=search   body: { "sequence": "ATGCCC..." }
 *   GET  ?action=get_seq&gene_id=1
 *   GET  ?action=list_seqs
 */

require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

$pdo    = getDBConnection();
$action = $_GET['action'] ?? 'search';

switch ($action) {

    // ── BLAST sequence search ─────────────────────────────────────────
    case 'search': {
        // Accept query sequence from POST body or GET param
        $input    = json_decode(file_get_contents('php://input'), true);
        $querySeq = strtoupper(trim($input['sequence'] ?? $_GET['sequence'] ?? ''));

        if (strlen($querySeq) < 10) {
            sendJSON(['error' => 'Query sequence must be at least 10 nucleotides'], 400);
        }

        // Sanitize: allow only IUPAC nucleotide characters
        if (!preg_match('/^[ATGCUNRYMKSWHBVD]+$/i', $querySeq)) {
            sendJSON(['error' => 'Invalid sequence characters. Use standard IUPAC nucleotide codes (ATGC...)'], 400);
        }

        // Retrieve all sequences from DB
        $stmt = $pdo->query(
            "SELECT bs.seq_id, bs.gene_id, bs.sequence, bs.seq_length,
                    bs.gc_content, bs.accession, bs.species,
                    g.gene_symbol, g.gene_name, g.chromosome, g.description
             FROM blast_sequences bs
             JOIN genes g ON bs.gene_id = g.gene_id"
        );
        $dbSeqs = $stmt->fetchAll();

        $queryLen = strlen($querySeq);
        $results  = [];

        foreach ($dbSeqs as $row) {
            $subject    = strtoupper($row['sequence']);
            $subjLen    = strlen($subject);

            // --- Sliding window alignment ---
            $windowSize = min($queryLen, $subjLen);
            $bestIdent  = 0;
            $bestQStart = 1;
            $bestQEnd   = $windowSize;
            $bestSStart = 1;
            $bestSEnd   = $windowSize;
            $bestMismatches = $windowSize;

            // Try each starting position in both sequences
            $searchLen = max(1, $windowSize - 10);
            for ($s = 0; $s < min($subjLen - $searchLen, 200); $s++) {
                for ($q = 0; $q < min($queryLen - $searchLen, 200); $q++) {
                    $len     = min($queryLen - $q, $subjLen - $s, 60);
                    if ($len < 10) continue;
                    $qSub    = substr($querySeq, $q, $len);
                    $sSub    = substr($subject,  $s, $len);
                    $matches = 0;
                    for ($i = 0; $i < $len; $i++) {
                        if ($qSub[$i] === $sSub[$i]) $matches++;
                    }
                    $identPct = $matches / $len * 100;
                    if ($identPct > $bestIdent) {
                        $bestIdent  = $identPct;
                        $bestQStart = $q + 1;
                        $bestQEnd   = $q + $len;
                        $bestSStart = $s + 1;
                        $bestSEnd   = $s + $len;
                        $bestMismatches = $len - $matches;
                    }
                }
            }

            // Also check direct substring match
            $pos = strpos($subject, substr($querySeq, 0, min(20, $queryLen)));
            if ($pos !== false) {
                $bestIdent = max($bestIdent, 95.0);
            }

            if ($bestIdent >= 40) {
                // Approximate E-value and bit-score (heuristic)
                $lambda = 1.37; $K = 0.711;
                $dbSize = array_sum(array_column($dbSeqs, 'seq_length')) ?: 10000;
                $score  = $bestIdent * 0.5 - 3;
                $eValue = $K * $queryLen * $dbSize * exp(-$lambda * $score);
                $bitScore = ($lambda * $score - log($K)) / log(2);

                $results[] = [
                    'gene_id'      => (int)$row['gene_id'],
                    'gene_symbol'  => $row['gene_symbol'],
                    'gene_name'    => $row['gene_name'],
                    'chromosome'   => $row['chromosome'],
                    'description'  => $row['description'],
                    'accession'    => $row['accession'],
                    'species'      => $row['species'],
                    'identity_pct' => round($bestIdent, 2),
                    'align_length' => $bestQEnd - $bestQStart + 1,
                    'mismatches'   => $bestMismatches,
                    'gap_opens'    => 0,
                    'query_start'  => $bestQStart,
                    'query_end'    => $bestQEnd,
                    'subject_start'=> $bestSStart,
                    'subject_end'  => $bestSEnd,
                    'e_value'      => round($eValue, 8),
                    'bit_score'    => round(max($bitScore, 0), 1),
                    'seq_length'   => (int)$row['seq_length'],
                    'gc_content'   => (float)$row['gc_content'],
                ];
            }
        }

        // Sort by identity descending
        usort($results, fn($a, $b) => $b['identity_pct'] <=> $a['identity_pct']);
        $results = array_slice($results, 0, 20); // top 20 hits

        // Log the search
        foreach (array_slice($results, 0, 5) as $hit) {
            $ins = $pdo->prepare(
                "INSERT INTO blast_results
                 (query_seq, matched_gene_id, identity_pct, align_length, mismatches,
                  gap_opens, query_start, query_end, subject_start, subject_end,
                  e_value, bit_score)
                 VALUES (:q,:gid,:ident,:alen,:mm,:gap,:qs,:qe,:ss,:se,:ev,:bs)"
            );
            $ins->execute([
                ':q'    => substr($querySeq, 0, 500),
                ':gid'  => $hit['gene_id'],
                ':ident'=> $hit['identity_pct'],
                ':alen' => $hit['align_length'],
                ':mm'   => $hit['mismatches'],
                ':gap'  => $hit['gap_opens'],
                ':qs'   => $hit['query_start'],
                ':qe'   => $hit['query_end'],
                ':ss'   => $hit['subject_start'],
                ':se'   => $hit['subject_end'],
                ':ev'   => $hit['e_value'],
                ':bs'   => $hit['bit_score'],
            ]);
        }

        sendJSON([
            'query_length' => $queryLen,
            'num_hits'     => count($results),
            'hits'         => $results,
        ]);
        break;
    }

    // ── Get sequence for a gene ────────────────────────────────────────
    case 'get_seq': {
        $geneId = (int)($_GET['gene_id'] ?? 0);
        $symbol = trim($_GET['symbol'] ?? '');

        if ($geneId <= 0 && $symbol === '') {
            sendJSON(['error' => 'Provide "gene_id" or "symbol"'], 400);
        }

        if ($symbol !== '') {
            $stmt = $pdo->prepare(
                "SELECT bs.*, g.gene_symbol, g.gene_name
                 FROM blast_sequences bs
                 JOIN genes g ON bs.gene_id = g.gene_id
                 WHERE g.gene_symbol = :sym"
            );
            $stmt->execute([':sym' => strtoupper($symbol)]);
        } else {
            $stmt = $pdo->prepare(
                "SELECT bs.*, g.gene_symbol, g.gene_name
                 FROM blast_sequences bs
                 JOIN genes g ON bs.gene_id = g.gene_id
                 WHERE bs.gene_id = :id"
            );
            $stmt->execute([':id' => $geneId]);
        }

        $seq = $stmt->fetch();
        if (!$seq) {
            sendJSON(['error' => 'Sequence not found'], 404);
        }
        sendJSON($seq);
        break;
    }

    // ── List all sequences ─────────────────────────────────────────────
    case 'list_seqs': {
        $stmt = $pdo->query(
            "SELECT bs.seq_id, bs.gene_id, g.gene_symbol, g.gene_name,
                    bs.seq_type, bs.species, bs.seq_length, bs.gc_content, bs.accession
             FROM blast_sequences bs
             JOIN genes g ON bs.gene_id = g.gene_id
             ORDER BY g.gene_symbol"
        );
        $seqs = $stmt->fetchAll();
        sendJSON(['count' => count($seqs), 'sequences' => $seqs]);
        break;
    }

    default:
        sendJSON(['error' => 'Unknown action'], 400);
}
