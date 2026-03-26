-- ============================================================
-- Breast Cancer RNA-seq Database Schema
-- Database: breast_cancer_rna_seq
-- ============================================================

CREATE DATABASE IF NOT EXISTS breast_cancer_rna_seq
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE breast_cancer_rna_seq;

-- ------------------------------------------------------------
-- Table: genes
-- Stores core gene information
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS genes (
    gene_id       INT          NOT NULL AUTO_INCREMENT,
    gene_name     VARCHAR(200) NOT NULL,
    gene_symbol   VARCHAR(50)  NOT NULL,
    chromosome    VARCHAR(10)  NOT NULL,
    start_pos     BIGINT,
    end_pos       BIGINT,
    strand        CHAR(1),
    description   TEXT,
    gene_type     VARCHAR(50)  DEFAULT 'protein_coding',
    ncbi_id       VARCHAR(30),
    ensembl_id    VARCHAR(30),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (gene_id),
    UNIQUE KEY uq_gene_symbol (gene_symbol),
    INDEX idx_gene_name (gene_name),
    INDEX idx_chromosome (chromosome)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Table: samples
-- Metadata about each sequencing sample
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS samples (
    sample_id     INT          NOT NULL AUTO_INCREMENT,
    sample_name   VARCHAR(100) NOT NULL,
    sample_type   ENUM('normal','tumor') NOT NULL,
    patient_id    VARCHAR(50),
    tissue_type   VARCHAR(100) DEFAULT 'breast',
    cancer_stage  VARCHAR(20),
    age           INT,
    gender        ENUM('F','M','unknown') DEFAULT 'F',
    source        VARCHAR(200),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sample_id),
    INDEX idx_sample_type (sample_type),
    INDEX idx_patient (patient_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Table: expression_data
-- RNA-seq expression values per gene per sample
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expression_data (
    expr_id             INT           NOT NULL AUTO_INCREMENT,
    gene_id             INT           NOT NULL,
    tissue_type         VARCHAR(100)  NOT NULL DEFAULT 'breast',
    normal_expression   FLOAT         NOT NULL COMMENT 'TPM in normal tissue',
    cancer_expression   FLOAT         NOT NULL COMMENT 'TPM in cancer tissue',
    fold_change         FLOAT         COMMENT 'Cancer/Normal ratio',
    log2_fold_change    FLOAT         COMMENT 'log2(fold_change)',
    p_value             DOUBLE,
    adj_p_value         DOUBLE        COMMENT 'BH-adjusted p-value',
    is_significant      TINYINT(1)    DEFAULT 0 COMMENT '1 if padj<0.05',
    regulation          ENUM('up','down','unchanged') DEFAULT 'unchanged',
    created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (expr_id),
    FOREIGN KEY fk_expr_gene (gene_id) REFERENCES genes(gene_id) ON DELETE CASCADE,
    INDEX idx_gene_id (gene_id),
    INDEX idx_regulation (regulation),
    INDEX idx_significant (is_significant)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Table: blast_sequences
-- Gene sequences used for BLAST searches
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS blast_sequences (
    seq_id        INT          NOT NULL AUTO_INCREMENT,
    gene_id       INT          NOT NULL,
    sequence      LONGTEXT     NOT NULL COMMENT 'mRNA/CDS sequence',
    seq_type      ENUM('mRNA','CDS','protein') DEFAULT 'mRNA',
    species       VARCHAR(100) NOT NULL DEFAULT 'Homo sapiens',
    seq_length    INT,
    gc_content    FLOAT        COMMENT 'GC% of the sequence',
    accession     VARCHAR(50),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (seq_id),
    FOREIGN KEY fk_seq_gene (gene_id) REFERENCES genes(gene_id) ON DELETE CASCADE,
    INDEX idx_seq_gene (gene_id),
    INDEX idx_species (species)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Table: blast_results (cache/log of BLAST searches)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS blast_results (
    result_id     INT          NOT NULL AUTO_INCREMENT,
    query_seq     TEXT         NOT NULL,
    matched_gene_id INT,
    identity_pct  FLOAT,
    align_length  INT,
    mismatches    INT,
    gap_opens     INT,
    query_start   INT,
    query_end     INT,
    subject_start INT,
    subject_end   INT,
    e_value       DOUBLE,
    bit_score     FLOAT,
    searched_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY fk_result_gene (matched_gene_id) REFERENCES genes(gene_id) ON DELETE SET NULL,
    INDEX idx_matched_gene (matched_gene_id)
) ENGINE=InnoDB;
