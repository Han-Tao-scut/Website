/**
 * query.js – Gene search functionality
 */

const API_GENES = '../php/api_genes.php';
const API_EXPR  = '../php/api_expression.php';

let currentPage = 1;
const PAGE_SIZE = 20;

// ── Initialise on page load ──────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    setupSearch();
    loadGeneList(1);
});

// ── Search bar setup ─────────────────────────────────────────
function setupSearch() {
    const searchInput = document.getElementById('searchInput');
    const searchBtn   = document.getElementById('searchBtn');
    const clearBtn    = document.getElementById('clearBtn');

    searchBtn.addEventListener('click', doSearch);
    clearBtn.addEventListener('click', clearSearch);
    searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') doSearch();
    });
}

function doSearch() {
    const q = document.getElementById('searchInput').value.trim();
    if (!q) { clearSearch(); return; }
    document.getElementById('listSection').classList.add('d-none');
    document.getElementById('searchSection').classList.remove('d-none');
    fetchSearchResults(q);
}

function clearSearch() {
    document.getElementById('searchInput').value = '';
    document.getElementById('searchSection').classList.add('d-none');
    document.getElementById('listSection').classList.remove('d-none');
    loadGeneList(currentPage);
}

// ── Search results ────────────────────────────────────────────
async function fetchSearchResults(query) {
    const container = document.getElementById('searchResults');
    container.innerHTML = '<div class="loading-overlay"><div class="spinner"></div><p>Searching...</p></div>';

    try {
        const res  = await fetch(`${API_GENES}?action=search&q=${encodeURIComponent(query)}`);
        const data = await res.json();

        if (data.error) { container.innerHTML = alertHTML('danger', data.error); return; }

        document.getElementById('searchCount').textContent =
            `Found ${data.count} result(s) for "${data.query}"`;

        if (data.count === 0) {
            container.innerHTML = alertHTML('info', 'No genes found matching your query.');
            return;
        }

        container.innerHTML = buildResultsTable(data.results);
    } catch (err) {
        container.innerHTML = alertHTML('danger', 'Network error: ' + err.message);
    }
}

function buildResultsTable(genes) {
    const rows = genes.map(g => `
        <tr>
          <td><a href="#" class="gene-link" data-id="${g.gene_id}">${g.gene_symbol}</a></td>
          <td>${g.gene_name}</td>
          <td>${g.chromosome}</td>
          <td>${g.normal_expression !== null ? parseFloat(g.normal_expression).toFixed(2) : '—'}</td>
          <td>${g.cancer_expression !== null ? parseFloat(g.cancer_expression).toFixed(2) : '—'}</td>
          <td>${g.log2_fold_change !== null ? fmtFC(g.log2_fold_change) : '—'}</td>
          <td>${g.p_value !== null ? g.p_value.toExponential(2) : '—'}</td>
          <td>${regulationBadge(g.regulation)}</td>
          <td>
            <button class="btn btn-primary btn-sm" onclick="openGeneDetail(${g.gene_id})">Detail</button>
            <a href="expression.html?gene_id=${g.gene_id}" class="btn btn-secondary btn-sm">Plot</a>
          </td>
        </tr>`).join('');

    return `
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Symbol</th><th>Name</th><th>Chr</th>
              <th>Normal TPM</th><th>Cancer TPM</th>
              <th>Log2FC</th><th>P-value</th><th>Regulation</th><th>Action</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>`;
}

// ── Gene list (paginated) ────────────────────────────────────
async function loadGeneList(page) {
    currentPage = page;
    const container = document.getElementById('geneList');
    const pagination = document.getElementById('pagination');
    container.innerHTML = '<div class="loading-overlay"><div class="spinner"></div><p>Loading genes...</p></div>';

    try {
        const res  = await fetch(`${API_GENES}?action=list&page=${page}&limit=${PAGE_SIZE}`);
        const data = await res.json();

        if (data.error) { container.innerHTML = alertHTML('danger', data.error); return; }

        container.innerHTML = buildResultsTable(data.genes);
        pagination.innerHTML = buildPagination(data.page, data.pages);
    } catch (err) {
        container.innerHTML = alertHTML('danger', 'Network error: ' + err.message);
    }
}

function buildPagination(current, total) {
    if (total <= 1) return '';
    let html = '';
    html += `<button ${current === 1 ? 'disabled' : ''} onclick="loadGeneList(${current - 1})">‹ Prev</button>`;
    for (let i = 1; i <= total; i++) {
        html += `<button class="${i === current ? 'active' : ''}" onclick="loadGeneList(${i})">${i}</button>`;
    }
    html += `<button ${current === total ? 'disabled' : ''} onclick="loadGeneList(${current + 1})">Next ›</button>`;
    return html;
}

// ── Gene detail modal ─────────────────────────────────────────
async function openGeneDetail(geneId) {
    const modal   = document.getElementById('geneModal');
    const content = document.getElementById('modalContent');
    modal.classList.remove('d-none');
    content.innerHTML = '<div class="loading-overlay"><div class="spinner"></div><p>Loading...</p></div>';

    try {
        const res  = await fetch(`${API_GENES}?action=get&id=${geneId}`);
        const gene = await res.json();

        if (gene.error) { content.innerHTML = alertHTML('danger', gene.error); return; }

        content.innerHTML = buildGeneDetail(gene);
    } catch (err) {
        content.innerHTML = alertHTML('danger', 'Network error: ' + err.message);
    }
}

function buildGeneDetail(g) {
    const lfc = g.log2_fold_change !== null ? parseFloat(g.log2_fold_change).toFixed(3) : '—';
    const sig = g.is_significant == 1 ? '<span class="badge badge-sig">Significant</span>' : '';
    return `
      <div class="gene-detail">
        <div>
          <div class="detail-row"><span class="detail-label">Symbol:</span>
            <span class="detail-value"><strong>${g.gene_symbol}</strong></span></div>
          <div class="detail-row"><span class="detail-label">Name:</span>
            <span class="detail-value">${g.gene_name}</span></div>
          <div class="detail-row"><span class="detail-label">Chromosome:</span>
            <span class="detail-value">${g.chromosome}${g.strand ? ' (' + g.strand + ')' : ''}</span></div>
          <div class="detail-row"><span class="detail-label">Gene Type:</span>
            <span class="detail-value">${g.gene_type || '—'}</span></div>
          <div class="detail-row"><span class="detail-label">NCBI ID:</span>
            <span class="detail-value">${g.ncbi_id ? `<a href="https://www.ncbi.nlm.nih.gov/gene/${g.ncbi_id}" target="_blank">${g.ncbi_id}</a>` : '—'}</span></div>
          <div class="detail-row"><span class="detail-label">Ensembl ID:</span>
            <span class="detail-value">${g.ensembl_id || '—'}</span></div>
        </div>
        <div>
          <div class="detail-row"><span class="detail-label">Normal TPM:</span>
            <span class="detail-value">${g.normal_expression !== null ? parseFloat(g.normal_expression).toFixed(2) : '—'}</span></div>
          <div class="detail-row"><span class="detail-label">Cancer TPM:</span>
            <span class="detail-value">${g.cancer_expression !== null ? parseFloat(g.cancer_expression).toFixed(2) : '—'}</span></div>
          <div class="detail-row"><span class="detail-label">Log2 Fold Change:</span>
            <span class="detail-value">${lfc} ${regulationBadge(g.regulation)}</span></div>
          <div class="detail-row"><span class="detail-label">P-value:</span>
            <span class="detail-value">${g.p_value !== null ? parseFloat(g.p_value).toExponential(2) : '—'} ${sig}</span></div>
          <div class="detail-row"><span class="detail-label">Adj. P-value:</span>
            <span class="detail-value">${g.adj_p_value !== null ? parseFloat(g.adj_p_value).toExponential(2) : '—'}</span></div>
        </div>
        <div class="full-width">
          <div class="detail-row"><span class="detail-label">Description:</span>
            <span class="detail-value">${g.description || 'No description available.'}</span></div>
        </div>
      </div>
      <div class="btn-group mt-2">
        <a href="expression.html?gene_id=${g.gene_id}" class="btn btn-primary">View Expression Plot</a>
        <a href="blast.html" class="btn btn-secondary">BLAST Search</a>
      </div>`;
}

function closeModal() {
    document.getElementById('geneModal').classList.add('d-none');
}

// ── Helpers ───────────────────────────────────────────────────
function regulationBadge(reg) {
    const map = { up: 'badge-up', down: 'badge-down', unchanged: 'badge-unchanged' };
    const cls = map[reg] || 'badge-unchanged';
    const lbl = reg ? reg.charAt(0).toUpperCase() + reg.slice(1) : 'N/A';
    return `<span class="badge ${cls}">${lbl}</span>`;
}

function fmtFC(val) {
    const v = parseFloat(val);
    const cls = v > 1 ? 'text-danger' : (v < -1 ? 'text-success' : '');
    return `<span class="${cls}">${v >= 0 ? '+' : ''}${v.toFixed(2)}</span>`;
}

function alertHTML(type, msg) {
    return `<div class="alert alert-${type}">${msg}</div>`;
}
