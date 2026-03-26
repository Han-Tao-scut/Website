# 🧬 BreastCancerDB – Breast Cancer RNA-seq Analysis Platform

A comprehensive web-based platform for analyzing breast cancer-related gene RNA-seq expression data. Built with PHP, MySQL, HTML/CSS/JavaScript for XAMPP on Linux.

## 📋 Project Overview

This project provides:
- **Database**: MySQL with E-R model storing gene information, expression data, BLAST sequences, and sample metadata
- **Backend**: PHP RESTful API for all CRUD operations
- **Frontend**: Responsive HTML/CSS/JavaScript pages with interactive charts
- **Virtual Dataset**: ~100 breast cancer-related genes with simulated RNA-seq expression data

## 📁 Project Structure

```
Website/
├── index.html                  # Home page (statistics, overview)
├── css/
│   └── style.css               # Global responsive stylesheet
├── js/
│   ├── query.js                # Gene search functionality
│   ├── blast.js                # BLAST sequence search
│   ├── visualization.js        # Chart.js expression plots
│   └── management.js           # CRUD operations UI
├── php/
│   ├── config.php              # Database connection & helpers
│   ├── api_genes.php           # Gene query API
│   ├── api_expression.php      # Expression data API
│   ├── api_blast.php           # BLAST search API
│   └── api_crud.php            # Create/Update/Delete API
├── database/
│   ├── schema.sql              # Database schema (tables, indexes, FK)
│   └── sample_data.sql         # Virtual dataset (~100 genes)
├── pages/
│   ├── query.html              # Gene search page
│   ├── blast.html              # BLAST sequence search page
│   ├── expression.html         # Expression visualization page
│   └── management.html         # Data management (CRUD) page
└── README.md
```

## 🗄️ Database E-R Model

Five tables form the relational schema:

```
genes (gene_id PK)
  ├── expression_data (gene_id FK)  – normal/cancer TPM, log2FC, p-value
  ├── blast_sequences (gene_id FK)  – mRNA sequences for BLAST
  └── blast_results   (matched_gene_id FK) – BLAST search log

samples – patient/sample metadata (tissue type, cancer stage, etc.)
```

**Key tables:**
| Table | Description |
|---|---|
| `genes` | Gene info: symbol, name, chromosome, NCBI/Ensembl IDs |
| `expression_data` | TPM values, log2 fold change, p-value, regulation status |
| `blast_sequences` | mRNA sequences for BLAST search |
| `samples` | Sample metadata (normal/tumor, patient ID, stage) |
| `blast_results` | Log of BLAST search queries and hits |

## 🚀 Setup Instructions (XAMPP on Linux)

### 1. Start XAMPP

```bash
sudo /opt/lampp/lampp start
# or use the XAMPP manager GUI
sudo /opt/lampp/manager-linux-x64.run
```

### 2. Deploy the Project

```bash
# Copy to XAMPP web root
sudo cp -r /path/to/Website /opt/lampp/htdocs/

# Or clone directly
cd /opt/lampp/htdocs/
git clone https://github.com/Han-Tao-scut/Website.git
```

### 3. Create the Database

```bash
# Open MySQL CLI
/opt/lampp/bin/mysql -u root

# Create and populate the database
mysql> SOURCE /opt/lampp/htdocs/Website/database/schema.sql;
mysql> SOURCE /opt/lampp/htdocs/Website/database/sample_data.sql;
mysql> exit
```

Or use **phpMyAdmin** at `http://localhost/phpmyadmin`:
1. Create database `breast_cancer_rna_seq`
2. Import `database/schema.sql`
3. Import `database/sample_data.sql`

### 4. Configure Database Connection

Edit `php/config.php` if your MySQL setup differs from defaults:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');          // Default XAMPP has no password
define('DB_NAME', 'breast_cancer_rna_seq');
```

### 5. Access the Website

Open your browser and go to:
```
http://localhost/Website/index.html
```

## 📊 Features

### Home Page (`index.html`)
- Dataset statistics (total genes, up/down-regulated counts, samples)
- Data source information
- Quick navigation to all features
- Gene symbol browser

### Gene Query (`pages/query.html`)
- Search by gene symbol, name, or NCBI ID
- Paginated table of all genes
- Detailed gene information modal
- Links to expression plots
- Direct navigation to BLAST search

### BLAST Search (`pages/blast.html`)
- Paste nucleotide sequences (FASTA or raw)
- Sliding-window alignment against all database sequences
- Results ranked by identity percentage, E-value, bit score
- One-click load of example sequences from database
- All searches logged to `blast_results` table

### Expression Viewer (`pages/expression.html`)
- Per-gene bar chart: normal vs cancer TPM
- Volcano plot for all genes (interactive)
- Top 20 differentially expressed genes (horizontal bar chart)
- URL parameter support: `expression.html?symbol=TP53`

### Data Management (`pages/management.html`)
- **Create**: Add new gene with expression values
- **Read**: Searchable, paginated gene table
- **Update**: Edit any gene or expression record
- **Delete**: Remove gene and all associated data (CASCADE)

## 🔌 API Reference

### Gene API (`php/api_genes.php`)
```
GET ?action=search&q=TP53          Search genes
GET ?action=get&id=1               Get single gene
GET ?action=list&page=1&limit=20   Paginated list
GET ?action=stats                  Database statistics
```

### Expression API (`php/api_expression.php`)
```
GET ?action=get_by_gene&symbol=TP53    Expression for one gene
GET ?action=top_degs&n=20             Top DEGs
GET ?action=volcano                    All genes for volcano plot
GET ?action=heatmap&symbols=TP53,BRCA1 Multiple genes
```

### BLAST API (`php/api_blast.php`)
```
POST ?action=search  body: {"sequence":"ATGCCC..."}   BLAST search
GET  ?action=get_seq&symbol=TP53                       Get sequence
GET  ?action=list_seqs                                  List all sequences
```

### CRUD API (`php/api_crud.php`)
```
POST ?action=create         Create new gene
POST ?action=update         Update gene fields
POST ?action=delete         Delete gene (+ cascade)
POST ?action=update_expression  Update expression data
```

## 🧬 Virtual Dataset

The virtual dataset includes **~100 breast cancer-related genes** covering:

| Category | Examples |
|---|---|
| Tumor Suppressors | TP53, BRCA1, BRCA2, PTEN, RB1, CDH1 |
| Oncogenes | HER2 (ERBB2), MYC, KRAS, MET, SRC |
| Cell Cycle | CCND1, CDK4/6, CDKN1A, CDKN2A, MKI67 |
| PI3K/AKT/mTOR | PIK3CA, AKT1, PTEN, MTOR, TSC1/2 |
| Hormone Receptors | ESR1, PGR, CYP19A1 |
| EMT Markers | VIM, CDH1, TWIST1, SNAI1, ZEB1, FN1 |
| Stem Cell | CD44, ALDH1A1, SOX2, NANOG, OCT4 |
| Epigenetics | EZH2, DNMT1, HDAC1, BRD4, PARP1 |
| DNA Repair | ATM, CHEK1/2, RAD51, PALB2, FANCA |

Expression values are **simulated** in TPM format, comparing:
- **Normal**: Normal breast tissue
- **Cancer**: Breast cancer tissue

## 📚 Learning Objectives

Working through this project helps you learn:

1. **Database Design**: E-R model, normalization, foreign keys, indexes
2. **SQL**: CREATE TABLE, INSERT, SELECT with JOINs, UPDATE, DELETE
3. **PHP**: PDO connections, prepared statements, REST API design
4. **JavaScript**: Fetch API, async/await, DOM manipulation
5. **HTML/CSS**: Responsive layouts, flexbox/grid, forms
6. **Chart.js**: Bar charts, scatter plots, dynamic data visualization
7. **CRUD Operations**: Complete Create-Read-Update-Delete cycle

## 🔮 Next Steps (Real Data Integration)

When you have real RNA-seq data:

1. **Replace virtual data**: Clear `expression_data` and reload with real TPM values
2. **Real sequences**: Update `blast_sequences` with actual mRNA sequences from NCBI
3. **Real BLAST**: Integrate NCBI BLAST+ command-line tool or BioPython
4. **More samples**: Add real TCGA sample metadata to `samples` table
5. **Statistical rigor**: Use R/DESeq2 or Python/PyDESeq2 for proper differential expression

## 📖 References

- TCGA Breast Cancer Dataset: https://portal.gdc.cancer.gov/
- NCBI Gene: https://www.ncbi.nlm.nih.gov/gene/
- Ensembl: https://www.ensembl.org/
- Chart.js: https://www.chartjs.org/

---

**Data Source Note**: All expression values in this version are **simulated/virtual** data for learning and development purposes. They will be replaced with real TCGA RNA-seq data in the production version.