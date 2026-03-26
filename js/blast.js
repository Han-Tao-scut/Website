/**
 * blast.js – BLAST sequence search functionality
 */

const API_BLAST = '../php/api_blast.php';

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('blastBtn').addEventListener('click', runBlast);
    document.getElementById('clearBlastBtn').addEventListener('click', clearBlast);
    document.getElementById('seqInput').addEventListener('keydown', (e) => {
        if (e.ctrlKey && e.key === 'Enter') runBlast();
    });
    loadSampleSequences();
});

// ── Run BLAST search ─────────────────────────────────────────
async function runBlast() {
    const rawSeq  = document.getElementById('seqInput').value.trim();
    const results = document.getElementById('blastResults');
    const summary = document.getElementById('blastSummary');

    if (!rawSeq) {
        results.innerHTML = alertHTML('warning', 'Please enter a nucleotide sequence.');
        return;
    }

    // Strip FASTA header and whitespace
    const seqLines = rawSeq.split('\n').filter(l => !l.startsWith('>'));
    const sequence = seqLines.join('').replace(/\s+/g, '').toUpperCase();

    if (sequence.length < 10) {
        results.innerHTML = alertHTML('warning', 'Sequence is too short (minimum 10 nucleotides).');
        return;
    }

    summary.textContent = '';
    results.innerHTML = '<div class="loading-overlay"><div class="spinner"></div><p>Running BLAST search...</p></div>';

    try {
        const res  = await fetch(API_BLAST + '?action=search', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ sequence }),
        });
        const data = await res.json();

        if (data.error) { results.innerHTML = alertHTML('danger', data.error); return; }

        summary.textContent =
            `Query length: ${data.query_length} nt | Hits found: ${data.num_hits}`;

        if (data.num_hits === 0) {
            results.innerHTML = alertHTML('info', 'No significant hits found (identity < 40%). Try a longer or different sequence.');
            return;
        }

        results.innerHTML = data.hits.map(hit => buildHitHTML(hit)).join('');
    } catch (err) {
        results.innerHTML = alertHTML('danger', 'Network error: ' + err.message);
    }
}

function buildHitHTML(hit) {
    const evalStr   = hit.e_value < 1e-5 ? hit.e_value.toExponential(2) : hit.e_value.toFixed(5);
    const identPct  = parseFloat(hit.identity_pct);
    const identColor = identPct >= 90 ? 'var(--success)' : identPct >= 70 ? 'var(--warning)' : 'var(--primary)';

    return `
      <div class="blast-hit">
        <div class="blast-hit-header">
          <div>
            <span class="blast-hit-title">${hit.gene_symbol} – ${hit.gene_name}</span>
            <span class="badge ${identPct >= 80 ? 'badge-up' : 'badge-unchanged'} ml-1">
              ${identPct.toFixed(1)}% identity
            </span>
          </div>
          <div class="blast-hit-score">
            Score: ${hit.bit_score} bits &nbsp;|&nbsp; E-value: ${evalStr}
          </div>
        </div>
        <div class="identity-bar">
          <div class="identity-fill" style="width:${Math.min(identPct,100)}%; background: linear-gradient(90deg, ${identColor}aa, ${identColor})"></div>
        </div>
        <div class="blast-stats mt-1">
          <div class="blast-stat">Identity: <span>${identPct.toFixed(1)}%</span></div>
          <div class="blast-stat">Length: <span>${hit.align_length}</span></div>
          <div class="blast-stat">Mismatches: <span>${hit.mismatches}</span></div>
          <div class="blast-stat">Gaps: <span>${hit.gap_opens}</span></div>
          <div class="blast-stat">Q: <span>${hit.query_start}–${hit.query_end}</span></div>
          <div class="blast-stat">S: <span>${hit.subject_start}–${hit.subject_end}</span></div>
          <div class="blast-stat">Chromosome: <span>${hit.chromosome}</span></div>
          <div class="blast-stat">Species: <span>${hit.species}</span></div>
        </div>
        ${hit.description ? `<p class="text-muted mt-1" style="font-size:.85rem">${hit.description}</p>` : ''}
        <div class="btn-group mt-1">
          <a href="expression.html?gene_id=${hit.gene_id}" class="btn btn-primary btn-sm">View Expression</a>
          <a href="query.html?q=${encodeURIComponent(hit.gene_symbol)}" class="btn btn-secondary btn-sm">Gene Details</a>
        </div>
      </div>`;
}

// ── Clear ─────────────────────────────────────────────────────
function clearBlast() {
    document.getElementById('seqInput').value = '';
    document.getElementById('blastResults').innerHTML = '';
    document.getElementById('blastSummary').textContent = '';
}

// ── Load example sequences from DB ───────────────────────────
async function loadSampleSequences() {
    const container = document.getElementById('sampleSeqs');
    if (!container) return;

    try {
        const res  = await fetch(API_BLAST + '?action=list_seqs');
        const data = await res.json();
        if (!data.sequences || data.sequences.length === 0) return;

        const items = data.sequences.slice(0, 12).map(s =>
            `<button class="btn btn-sm btn-secondary" onclick="useExampleSeq('${s.gene_symbol}')">
               ${s.gene_symbol}
             </button>`
        ).join('');
        container.innerHTML = '<p class="text-muted mb-1">Click to load an example sequence:</p>' +
                              '<div class="btn-group flex-wrap">' + items + '</div>';
    } catch (_) {}
}

async function useExampleSeq(symbol) {
    try {
        const res  = await fetch(`${API_BLAST}?action=get_seq&symbol=${encodeURIComponent(symbol)}`);
        const data = await res.json();
        if (data.error) return;
        const fasta = `>${data.gene_symbol} | ${data.gene_name} | ${data.accession}\n${data.sequence}`;
        document.getElementById('seqInput').value = fasta;
    } catch (_) {}
}

// ── Helpers ───────────────────────────────────────────────────
function alertHTML(type, msg) {
    return `<div class="alert alert-${type}">${msg}</div>`;
}
