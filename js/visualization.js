/**
 * visualization.js – Expression data charts using Chart.js
 */

const API_EXPR  = '../php/api_expression.php';
const API_GENES = '../php/api_genes.php';

let barChart    = null;
let volcanoChart = null;
let heatmapChart = null;

document.addEventListener('DOMContentLoaded', () => {
    const params  = new URLSearchParams(window.location.search);
    const geneId  = params.get('gene_id');
    const symbol  = params.get('symbol');

    if (geneId || symbol) {
        // Pre-fill and show a specific gene
        if (geneId)  document.getElementById('geneSearchInput').value = geneId;
        if (symbol)  document.getElementById('geneSearchInput').value = symbol;
        loadGeneExpression();
    }

    document.getElementById('searchExprBtn').addEventListener('click', loadGeneExpression);
    document.getElementById('geneSearchInput').addEventListener('keydown', (e) => {
        if (e.key === 'Enter') loadGeneExpression();
    });

    loadVolcanoPlot();
    loadTopDEGs();
});

// ── Bar chart: normal vs cancer for one gene ─────────────────
async function loadGeneExpression() {
    const query   = document.getElementById('geneSearchInput').value.trim();
    const section = document.getElementById('geneExprSection');
    const loading = document.getElementById('geneExprLoading');
    const alert   = document.getElementById('geneExprAlert');

    if (!query) return;

    section.classList.add('d-none');
    alert.className = 'alert alert-hidden';
    loading.classList.remove('d-none');

    try {
        // Check if numeric (gene_id) or symbol
        const isId = /^\d+$/.test(query);
        const url  = isId
            ? `${API_EXPR}?action=get_by_gene&gene_id=${query}`
            : `${API_EXPR}?action=get_by_gene&symbol=${encodeURIComponent(query.toUpperCase())}`;

        const res  = await fetch(url);
        const data = await res.json();
        loading.classList.add('d-none');

        if (data.error) {
            alert.className = 'alert alert-danger';
            alert.textContent = data.error;
            return;
        }

        renderGeneExprChart(data);
        section.classList.remove('d-none');
    } catch (err) {
        loading.classList.add('d-none');
        alert.className = 'alert alert-danger';
        alert.textContent = 'Network error: ' + err.message;
    }
}

function renderGeneExprChart(g) {
    // Fill gene info panel
    document.getElementById('exprGeneSymbol').textContent = g.gene_symbol;
    document.getElementById('exprGeneName').textContent   = g.gene_name;

    const norm  = parseFloat(g.normal_expression);
    const canc  = parseFloat(g.cancer_expression);
    const lfc   = parseFloat(g.log2_fold_change);
    const pval  = parseFloat(g.p_value);

    document.getElementById('exprNormal').textContent = norm.toFixed(2) + ' TPM';
    document.getElementById('exprCancer').textContent = canc.toFixed(2) + ' TPM';
    document.getElementById('exprLFC').textContent    = (lfc >= 0 ? '+' : '') + lfc.toFixed(3);
    document.getElementById('exprPval').textContent   = pval.toExponential(2);
    document.getElementById('exprReg').innerHTML      = regulationBadge(g.regulation);

    // Destroy previous chart
    if (barChart) { barChart.destroy(); barChart = null; }

    const ctx = document.getElementById('exprBarChart').getContext('2d');
    barChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Normal Breast Tissue', 'Breast Cancer Tissue'],
            datasets: [{
                label: `${g.gene_symbol} Expression (TPM)`,
                data: [norm, canc],
                backgroundColor: ['rgba(52,152,219,.75)', 'rgba(192,57,43,.75)'],
                borderColor:     ['rgba(52,152,219,1)',   'rgba(192,57,43,1)'],
                borderWidth: 2,
                borderRadius: 6,
            }],
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                title: {
                    display: true,
                    text: `${g.gene_symbol} – Normal vs Cancer Expression`,
                    font: { size: 16 },
                },
                tooltip: {
                    callbacks: {
                        label: (ctx) => ` ${ctx.parsed.y.toFixed(2)} TPM`,
                    },
                },
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: { display: true, text: 'Expression (TPM)' },
                },
            },
        },
    });
}

// ── Volcano plot ─────────────────────────────────────────────
async function loadVolcanoPlot() {
    try {
        const res  = await fetch(`${API_EXPR}?action=volcano`);
        const data = await res.json();
        if (data.error || !data.data) return;

        renderVolcano(data.data);
    } catch (_) {}
}

function renderVolcano(genes) {
    if (volcanoChart) { volcanoChart.destroy(); volcanoChart = null; }

    const up       = genes.filter(g => g.regulation === 'up'   && g.is_significant == 1);
    const down     = genes.filter(g => g.regulation === 'down' && g.is_significant == 1);
    const ns       = genes.filter(g => g.is_significant != 1);

    const toPoint = (g) => ({
        x: parseFloat(g.log2_fold_change),
        y: parseFloat(g.neg_log10_pvalue),
        label: g.gene_symbol,
    });

    const ctx = document.getElementById('volcanoChart').getContext('2d');
    volcanoChart = new Chart(ctx, {
        type: 'scatter',
        data: {
            datasets: [
                {
                    label: 'Up-regulated',
                    data: up.map(toPoint),
                    backgroundColor: 'rgba(192,57,43,.65)',
                    pointRadius: 5,
                },
                {
                    label: 'Down-regulated',
                    data: down.map(toPoint),
                    backgroundColor: 'rgba(52,152,219,.65)',
                    pointRadius: 5,
                },
                {
                    label: 'Not significant',
                    data: ns.map(toPoint),
                    backgroundColor: 'rgba(127,140,141,.45)',
                    pointRadius: 4,
                },
            ],
        },
        options: {
            responsive: true,
            plugins: {
                title: { display: true, text: 'Volcano Plot – Differential Expression', font: { size: 15 } },
                tooltip: {
                    callbacks: {
                        label: (ctx) => {
                            const pt = ctx.raw;
                            return ` ${pt.label}  log2FC: ${pt.x.toFixed(2)},  -log10(p): ${pt.y.toFixed(2)}`;
                        },
                    },
                },
                annotation: {
                    annotations: {
                        lineFC_pos: { type: 'line', scaleID: 'x', value:  1, borderColor: '#aaa', borderWidth: 1, borderDash: [4,4] },
                        lineFC_neg: { type: 'line', scaleID: 'x', value: -1, borderColor: '#aaa', borderWidth: 1, borderDash: [4,4] },
                        linePval:   { type: 'line', scaleID: 'y', value:  1.301, borderColor: '#aaa', borderWidth: 1, borderDash: [4,4] },
                    },
                },
            },
            scales: {
                x: { title: { display: true, text: 'log2 Fold Change' } },
                y: { title: { display: true, text: '-log10(p-value)' } },
            },
        },
    });
}

// ── Top DEGs bar chart ────────────────────────────────────────
async function loadTopDEGs() {
    try {
        const res  = await fetch(`${API_EXPR}?action=top_degs&n=20&regulation=all`);
        const data = await res.json();
        if (data.error || !data.genes) return;

        renderTopDEGsChart(data.genes);
    } catch (_) {}
}

function renderTopDEGsChart(genes) {
    if (heatmapChart) { heatmapChart.destroy(); heatmapChart = null; }

    const labels = genes.map(g => g.gene_symbol);
    const lfcs   = genes.map(g => parseFloat(g.log2_fold_change));
    const colors = lfcs.map(v => v > 0 ? 'rgba(192,57,43,.75)' : 'rgba(52,152,219,.75)');

    const ctx = document.getElementById('topDEGsChart').getContext('2d');
    heatmapChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels,
            datasets: [{
                label: 'log2 Fold Change',
                data: lfcs,
                backgroundColor: colors,
                borderColor: colors.map(c => c.replace('.75', '1')),
                borderWidth: 1,
                borderRadius: 4,
            }],
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            plugins: {
                title: { display: true, text: 'Top 20 Differentially Expressed Genes', font: { size: 15 } },
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (ctx) => ` log2FC: ${ctx.parsed.x.toFixed(2)}`,
                    },
                },
            },
            scales: {
                x: { title: { display: true, text: 'log2 Fold Change' } },
            },
        },
    });
}

// ── Helpers ───────────────────────────────────────────────────
function regulationBadge(reg) {
    const map = { up: 'badge-up', down: 'badge-down', unchanged: 'badge-unchanged' };
    const cls = map[reg] || 'badge-unchanged';
    const lbl = reg ? reg.charAt(0).toUpperCase() + reg.slice(1) : 'N/A';
    return `<span class="badge ${cls}">${lbl}</span>`;
}
