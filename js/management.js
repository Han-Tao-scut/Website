/**
 * management.js – CRUD operations for gene records
 */

const API_CRUD  = '../php/api_crud.php';
const API_GENES = '../php/api_genes.php';

let editingGeneId = null;

document.addEventListener('DOMContentLoaded', () => {
    loadManagementList();
    setupFormHandlers();
});

// ── Load gene list in management table ───────────────────────
async function loadManagementList(query = '') {
    const tbody = document.getElementById('mgmtTableBody');
    tbody.innerHTML = '<tr><td colspan="7" class="text-center"><div class="spinner"></div> Loading...</td></tr>';

    try {
        let url;
        if (query) {
            url = `${API_GENES}?action=search&q=${encodeURIComponent(query)}`;
        } else {
            url = `${API_GENES}?action=list&page=1&limit=50`;
        }

        const res  = await fetch(url);
        const data = await res.json();

        if (data.error) { tbody.innerHTML = `<tr><td colspan="7">${alertHTML('danger', data.error)}</td></tr>`; return; }

        const genes = data.results || data.genes || [];
        if (genes.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">No records found.</td></tr>';
            return;
        }

        tbody.innerHTML = genes.map(g => `
          <tr id="row-${g.gene_id}">
            <td>${g.gene_id}</td>
            <td><strong>${g.gene_symbol}</strong></td>
            <td>${g.gene_name}</td>
            <td>${g.chromosome}</td>
            <td>${g.normal_expression !== null ? parseFloat(g.normal_expression).toFixed(1) : '—'} /
                ${g.cancer_expression !== null ? parseFloat(g.cancer_expression).toFixed(1) : '—'}</td>
            <td>${g.log2_fold_change !== null ? fmtFC(g.log2_fold_change) : '—'}</td>
            <td>
              <button class="btn btn-warning btn-sm" onclick="startEdit(${g.gene_id})">Edit</button>
              <button class="btn btn-danger  btn-sm" onclick="deleteGene(${g.gene_id}, '${g.gene_symbol}')">Delete</button>
            </td>
          </tr>`).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="7">${alertHTML('danger', err.message)}</td></tr>`;
    }
}

// ── Form handlers ─────────────────────────────────────────────
function setupFormHandlers() {
    document.getElementById('geneForm').addEventListener('submit', handleFormSubmit);
    document.getElementById('mgmtSearchBtn').addEventListener('click', () => {
        const q = document.getElementById('mgmtSearch').value.trim();
        loadManagementList(q);
    });
    document.getElementById('mgmtSearch').addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            loadManagementList(document.getElementById('mgmtSearch').value.trim());
        }
    });
    document.getElementById('cancelEditBtn').addEventListener('click', resetForm);
}

async function handleFormSubmit(e) {
    e.preventDefault();
    const action = editingGeneId ? 'update' : 'create';
    const alert  = document.getElementById('formAlert');

    const payload = {
        gene_symbol:        document.getElementById('fSymbol').value.trim(),
        gene_name:          document.getElementById('fName').value.trim(),
        chromosome:         document.getElementById('fChr').value.trim(),
        description:        document.getElementById('fDesc').value.trim(),
        ncbi_id:            document.getElementById('fNcbi').value.trim(),
        normal_expression:  document.getElementById('fNormExpr').value,
        cancer_expression:  document.getElementById('fCancExpr').value,
        p_value:            document.getElementById('fPval').value,
    };
    if (editingGeneId) payload.gene_id = editingGeneId;

    try {
        const method = action === 'create' ? 'POST' : 'POST';
        const res    = await fetch(`${API_CRUD}?action=${action}`, {
            method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        });
        const data = await res.json();

        if (data.error) {
            alert.className = 'alert alert-danger';
            alert.textContent = data.error;
        } else {
            alert.className = 'alert alert-success';
            alert.textContent = data.message || 'Operation successful';
            resetForm();
            loadManagementList();
            setTimeout(() => { alert.className = 'alert alert-hidden'; }, 3000);
        }
    } catch (err) {
        alert.className = 'alert alert-danger';
        alert.textContent = 'Network error: ' + err.message;
    }
}

// ── Edit a gene ───────────────────────────────────────────────
async function startEdit(geneId) {
    editingGeneId = geneId;

    try {
        const res  = await fetch(`${API_GENES}?action=get&id=${geneId}`);
        const gene = await res.json();
        if (gene.error) return;

        document.getElementById('fSymbol').value   = gene.gene_symbol || '';
        document.getElementById('fName').value     = gene.gene_name   || '';
        document.getElementById('fChr').value      = gene.chromosome  || '';
        document.getElementById('fDesc').value     = gene.description || '';
        document.getElementById('fNcbi').value     = gene.ncbi_id     || '';
        document.getElementById('fNormExpr').value = gene.normal_expression || '';
        document.getElementById('fCancExpr').value = gene.cancer_expression || '';
        document.getElementById('fPval').value     = gene.p_value     || '';

        document.getElementById('formTitle').textContent   = `Edit Gene: ${gene.gene_symbol}`;
        document.getElementById('submitBtn').textContent   = 'Update Gene';
        document.getElementById('submitBtn').className     = 'btn btn-warning';
        document.getElementById('cancelEditBtn').classList.remove('d-none');

        document.getElementById('geneFormSection').scrollIntoView({ behavior: 'smooth' });
    } catch (_) {}
}

// ── Delete a gene ─────────────────────────────────────────────
async function deleteGene(geneId, symbol) {
    if (!confirm(`Are you sure you want to delete gene "${symbol}" (ID: ${geneId})?\nThis will also remove all expression data for this gene.`)) return;

    const alert = document.getElementById('formAlert');
    try {
        const res  = await fetch(`${API_CRUD}?action=delete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ gene_id: geneId }),
        });
        const data = await res.json();

        alert.className = data.error ? 'alert alert-danger' : 'alert alert-success';
        alert.textContent = data.message || data.error;
        if (!data.error) {
            document.getElementById(`row-${geneId}`)?.remove();
            setTimeout(() => { alert.className = 'alert alert-hidden'; }, 3000);
        }
    } catch (err) {
        alert.className = 'alert alert-danger';
        alert.textContent = 'Network error: ' + err.message;
    }
}

// ── Reset form to Create mode ─────────────────────────────────
function resetForm() {
    editingGeneId = null;
    document.getElementById('geneForm').reset();
    document.getElementById('formTitle').textContent  = 'Add New Gene';
    document.getElementById('submitBtn').textContent  = 'Add Gene';
    document.getElementById('submitBtn').className    = 'btn btn-success';
    document.getElementById('cancelEditBtn').classList.add('d-none');
    document.getElementById('formAlert').className = 'alert alert-hidden';
}

// ── Helpers ───────────────────────────────────────────────────
function fmtFC(val) {
    const v = parseFloat(val);
    const cls = v > 1 ? 'text-danger' : (v < -1 ? 'text-success' : '');
    return `<span class="${cls}">${v >= 0 ? '+' : ''}${v.toFixed(2)}</span>`;
}

function alertHTML(type, msg) {
    return `<div class="alert alert-${type}">${msg}</div>`;
}
