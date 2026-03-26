-- ============================================================
-- Virtual Breast Cancer RNA-seq Sample Data
-- ~100 breast cancer-related genes with expression values
-- Data source: Simulated RNA-seq data (for learning/development)
-- ============================================================

USE breast_cancer_rna_seq;

-- ------------------------------------------------------------
-- Gene Records
-- ------------------------------------------------------------
INSERT INTO genes (gene_symbol, gene_name, chromosome, start_pos, end_pos, strand, description, gene_type, ncbi_id, ensembl_id) VALUES
('TP53',   'Tumor Protein P53',                                '17', 7661779,  7687538,  '-', 'Key tumor suppressor; mutated in ~30% of breast cancers',          'protein_coding', '7157',  'ENSG00000141510'),
('BRCA1',  'BRCA DNA Repair Associated 1',                    '17', 43044295, 43125482, '-', 'DNA repair gene; germline mutations cause hereditary breast cancer','protein_coding', '672',   'ENSG00000012048'),
('BRCA2',  'BRCA DNA Repair Associated 2',                    '13', 32315508, 32400268, '+', 'DNA repair gene; partner of BRCA1 in homologous recombination',    'protein_coding', '675',   'ENSG00000139618'),
('ESR1',   'Estrogen Receptor 1',                             '6',  151656691,151838051,'+', 'Estrogen receptor alpha; marker for luminal breast cancer',         'protein_coding', '2099',  'ENSG00000091831'),
('PGR',    'Progesterone Receptor',                           '11', 100913465,101019199,'+', 'Progesterone receptor; co-marker with ESR1',                        'protein_coding', '5241',  'ENSG00000082175'),
('ERBB2',  'Erb-B2 Receptor Tyrosine Kinase 2 (HER2)',        '17', 39688085, 39730426, '+', 'HER2 oncogene; amplified in ~20% of breast cancers',               'protein_coding', '2064',  'ENSG00000141736'),
('EGFR',   'Epidermal Growth Factor Receptor',                '7',  55086725, 55279321, '+', 'EGFR; overexpressed in triple-negative breast cancer',             'protein_coding', '1956',  'ENSG00000146648'),
('MYC',    'MYC Proto-Oncogene',                              '8',  127735434,127742951,'+', 'Transcription factor; amplified in aggressive breast cancers',     'protein_coding', '4609',  'ENSG00000136997'),
('PIK3CA', 'Phosphatidylinositol-4,5-Bisphosphate 3-Kinase Catalytic Subunit Alpha','3',179148114,179240695,'+','Frequently mutated PI3K in breast cancer',     'protein_coding', '5290',  'ENSG00000121879'),
('AKT1',   'AKT Serine/Threonine Kinase 1',                   '14', 104769349,104795743,'+', 'Key kinase in PI3K/AKT/mTOR signaling pathway',                   'protein_coding', '207',   'ENSG00000142208'),
('PTEN',   'Phosphatase And Tensin Homolog',                   '10', 89622870, 89731687, '+', 'Tumor suppressor; antagonizes PI3K signaling',                    'protein_coding', '5728',  'ENSG00000171862'),
('CDH1',   'Cadherin 1 (E-Cadherin)',                         '16', 68771195, 68868068, '-', 'Cell adhesion; loss drives epithelial-mesenchymal transition',     'protein_coding', '999',   'ENSG00000039068'),
('VEGFA',  'Vascular Endothelial Growth Factor A',            '6',  43770209, 43786487, '+', 'Angiogenesis driver; upregulated in breast tumors',                'protein_coding', '7422',  'ENSG00000112715'),
('MMP9',   'Matrix Metallopeptidase 9',                       '20', 46008908, 46016561, '+', 'Extracellular matrix remodeling; promotes invasion',              'protein_coding', '4318',  'ENSG00000100985'),
('CCND1',  'Cyclin D1',                                       '11', 69455855, 69469242, '+', 'Cell cycle regulator; amplified in luminal breast cancer',         'protein_coding', '595',   'ENSG00000110092'),
('CDK4',   'Cyclin Dependent Kinase 4',                       '12', 57747727, 57753172, '+', 'Cell cycle kinase; therapeutic target in HR+ breast cancer',      'protein_coding', '1019',  'ENSG00000135446'),
('CDK6',   'Cyclin Dependent Kinase 6',                       '7',  92234235, 92465908, '-', 'Cell cycle kinase; CDK4/6 inhibitors used clinically',            'protein_coding', '1021',  'ENSG00000105810'),
('RB1',    'RB Transcriptional Corepressor 1',                '13', 48303750, 48481890, '+', 'Tumor suppressor retinoblastoma protein',                         'protein_coding', '5925',  'ENSG00000139687'),
('KRAS',   'KRAS Proto-Oncogene, GTPase',                     '12', 25205246, 25250936, '-', 'RAS GTPase; less commonly mutated in breast vs other cancers',    'protein_coding', '3845',  'ENSG00000133703'),
('HRAS',   'HRas Proto-Oncogene, GTPase',                     '11', 534242,   535566,   '+', 'RAS family oncogene',                                             'protein_coding', '3265',  'ENSG00000174775'),
('NRAS',   'NRAS Proto-Oncogene, GTPase',                     '1',  114713909,114726096,'+', 'RAS family oncogene; activates MAPK pathway',                     'protein_coding', '4893',  'ENSG00000213281'),
('BRAF',   'B-Raf Proto-Oncogene, Serine/Threonine Kinase',   '7',  140419127,140624564,'-', 'MAP kinase; mutation leads to MAPK pathway activation',           'protein_coding', '673',   'ENSG00000157764'),
('MAP2K1', 'Mitogen-Activated Protein Kinase Kinase 1 (MEK1)','15', 66434228, 66519014, '+', 'MEK1; downstream of RAF in MAPK cascade',                         'protein_coding', '5604',  'ENSG00000169032'),
('MAPK1',  'Mitogen-Activated Protein Kinase 1 (ERK2)',       '22', 21754886, 21867638, '-', 'ERK2; terminal kinase in MAPK signaling',                         'protein_coding', '5594',  'ENSG00000100030'),
('MTOR',   'Mechanistic Target Of Rapamycin Kinase',          '1',  11106531, 11262561, '+', 'mTOR kinase; central regulator of cell growth',                   'protein_coding', '2475',  'ENSG00000198793'),
('TSC1',   'TSC Complex Subunit 1 (Hamartin)',                '9',  132889516,132982022,'+', 'mTOR pathway suppressor',                                         'protein_coding', '7248',  'ENSG00000165699'),
('TSC2',   'TSC Complex Subunit 2 (Tuberin)',                  '16', 2045165,  2143312,  '+', 'mTOR pathway suppressor; tuberous sclerosis',                     'protein_coding', '7249',  'ENSG00000103197'),
('STAT3',  'Signal Transducer And Activator Of Transcription 3','17',42313888, 42388441, '+', 'Transcription factor; activated by cytokines in breast cancer',   'protein_coding', '6774',  'ENSG00000168610'),
('JAK2',   'Janus Kinase 2',                                  '9',  4984174,  5128183,  '+', 'JAK kinase; activates STAT3 signaling',                           'protein_coding', '3717',  'ENSG00000096968'),
('IL6',    'Interleukin 6',                                   '7',  22725885, 22732002, '+', 'Cytokine; promotes breast cancer progression',                    'protein_coding', '3569',  'ENSG00000136244'),
('TNF',    'Tumor Necrosis Factor',                           '6',  31575566, 31578336, '+', 'Inflammatory cytokine; tumor microenvironment role',               'protein_coding', '7124',  'ENSG00000232810'),
('TGFB1',  'Transforming Growth Factor Beta 1',               '19', 41838512, 41858563, '+', 'TGFβ1; dual role as tumor suppressor and promoter',               'protein_coding', '7040',  'ENSG00000105329'),
('NOTCH1', 'Notch Receptor 1',                                '9',  136494433,136546047,'-', 'Notch pathway; stem cell maintenance in breast cancer',           'protein_coding', '4851',  'ENSG00000148400'),
('WNT5A',  'Wnt Family Member 5A',                            '3',  55498289, 55536528, '+', 'Wnt signaling; non-canonical pathway',                            'protein_coding', '7474',  'ENSG00000114251'),
('CTNNB1', 'Catenin Beta 1 (Beta-Catenin)',                   '3',  41194312, 41240751, '+', 'Beta-catenin; WNT pathway effector',                              'protein_coding', '1499',  'ENSG00000168036'),
('APC',    'APC Regulator Of WNT Signaling Pathway',          '5',  112707498,112846239,'+', 'WNT pathway tumor suppressor; APC complex',                       'protein_coding', '324',   'ENSG00000134982'),
('CASP8',  'Caspase 8',                                       '2',  202098166,202154201,'-', 'Apoptosis initiator caspase',                                     'protein_coding', '841',   'ENSG00000064012'),
('BCL2',   'BCL2 Apoptosis Regulator',                        '18', 63123347, 63320128, '+', 'Anti-apoptotic protein; overexpressed in breast cancer',          'protein_coding', '596',   'ENSG00000171791'),
('BCL2L1', 'BCL2 Like 1 (BCL-XL)',                            '20', 31664452, 31723989, '+', 'Anti-apoptotic BCL2 family; resistance to therapy',               'protein_coding', '598',   'ENSG00000171552'),
('BAX',    'BCL2 Associated X, Apoptosis Regulator',          '19', 48954131, 48961798, '-', 'Pro-apoptotic BCL2 family member',                                'protein_coding', '581',   'ENSG00000087088'),
('MDM2',   'MDM2 Proto-Oncogene',                             '12', 69201945, 69239080, '+', 'Negative regulator of TP53',                                      'protein_coding', '4193',  'ENSG00000135679'),
('CDKN1A', 'Cyclin Dependent Kinase Inhibitor 1A (p21)',      '6',  36644986, 36653199, '+', 'p21; TP53 target; cell cycle arrest',                             'protein_coding', '1026',  'ENSG00000124762'),
('CDKN2A', 'Cyclin Dependent Kinase Inhibitor 2A (p16)',      '9',  21967751, 21994490, '+', 'p16; CDK4/6 inhibitor; frequently silenced in cancer',            'protein_coding', '1029',  'ENSG00000147889'),
('E2F1',   'E2F Transcription Factor 1',                      '20', 34233253, 34257948, '-', 'Transcription factor; regulates S-phase entry',                   'protein_coding', '1869',  'ENSG00000101412'),
('FOXM1',  'Forkhead Box M1',                                 '12', 2966277,  2985898,  '+', 'Transcription factor; promotes proliferation',                    'protein_coding', '2305',  'ENSG00000111206'),
('AURKA',  'Aurora Kinase A',                                 '20', 57864978, 57906705, '+', 'Mitotic kinase; amplified in breast cancer',                      'protein_coding', '6790',  'ENSG00000087586'),
('AURKB',  'Aurora Kinase B',                                 '17', 8108819,  8118381,  '+', 'Mitotic kinase; chromosomal instability',                         'protein_coding', '9212',  'ENSG00000178999'),
('PLK1',   'Polo Like Kinase 1',                              '16', 23600623, 23611812, '-', 'Polo-like kinase; key mitotic regulator',                         'protein_coding', '5347',  'ENSG00000166851'),
('CHEK1',  'Checkpoint Kinase 1',                             '11', 125530100,125553020,'+', 'DNA damage checkpoint kinase',                                    'protein_coding', '1111',  'ENSG00000149554'),
('CHEK2',  'Checkpoint Kinase 2',                             '22', 28687743, 28742418, '+', 'DNA damage checkpoint; germline mutations in breast cancer',      'protein_coding', '11200', 'ENSG00000183765'),
('ATM',    'ATM Serine/Threonine Kinase',                     '11', 108222832,108369099,'+', 'DNA damage sensor; BRCA pathway',                                 'protein_coding', '472',   'ENSG00000149311'),
('RAD51',  'RAD51 Recombinase',                               '15', 40956164, 40975716, '-', 'DNA repair by homologous recombination',                          'protein_coding', '5888',  'ENSG00000051180'),
('PALB2',  'Partner And Localizer Of BRCA2',                  '16', 23603160, 23641310, '+', 'BRCA2 partner; high-risk breast cancer gene',                     'protein_coding', '79728', 'ENSG00000083093'),
('FANCA',  'Fanconi Anemia Complementation Group A',          '16', 89737747, 89815152, '+', 'Fanconi anemia pathway; DNA interstrand crosslink repair',        'protein_coding', '2175',  'ENSG00000187741'),
('NF1',    'Neurofibromin 1',                                 '17', 31094927, 31377677, '+', 'RAS-GAP; tumor suppressor; mutated in TNBC',                      'protein_coding', '4763',  'ENSG00000196712'),
('ARID1A', 'AT-Rich Interaction Domain 1A',                   '1',  26696838, 26876316, '-', 'Chromatin remodeling; SWI/SNF complex; tumor suppressor',         'protein_coding', '8289',  'ENSG00000117713'),
('KMT2C',  'Lysine Methyltransferase 2C (MLL3)',              '7',  151763450,152131775,'+', 'Histone H3K4 methyltransferase; chromatin regulation',            'protein_coding', '58508', 'ENSG00000055609'),
('GATA3',  'GATA Binding Protein 3',                          '10', 8095497,  8117619,  '+', 'Transcription factor; luminal differentiation marker',            'protein_coding', '2625',  'ENSG00000107485'),
('FOXA1',  'Forkhead Box A1',                                 '14', 37589826, 37600271, '-', 'Pioneer transcription factor; ERα co-activator',                  'protein_coding', '3169',  'ENSG00000129514'),
('RUNX2',  'RUNT Related Transcription Factor 2',             '6',  45348868, 45687689, '+', 'Transcription factor; bone metastasis in breast cancer',          'protein_coding', '860',   'ENSG00000124813'),
('TWIST1', 'Twist Family BHLH Transcription Factor 1',        '7',  19156530, 19159205, '-', 'EMT transcription factor; promotes metastasis',                   'protein_coding', '7291',  'ENSG00000122691'),
('SNAI1',  'Snail Family Transcriptional Repressor 1',        '20', 49976605, 49981584, '+', 'EMT transcription factor; represses E-cadherin',                  'protein_coding', '6615',  'ENSG00000124216'),
('ZEB1',   'Zinc Finger E-Box Binding Homeobox 1',            '10', 31318937, 31555530, '-', 'EMT transcription factor; metastasis driver',                     'protein_coding', '6935',  'ENSG00000148516'),
('VIM',    'Vimentin',                                        '10', 17270258, 17279592, '+', 'Mesenchymal marker; EMT indicator',                               'protein_coding', '7431',  'ENSG00000026025'),
('FN1',    'Fibronectin 1',                                   '2',  215360440,215632161,'-', 'Extracellular matrix protein; invasion and metastasis',           'protein_coding', '2335',  'ENSG00000115414'),
('MMP2',   'Matrix Metallopeptidase 2',                       '16', 55399679, 55440573, '+', 'Gelatinase A; basement membrane degradation',                    'protein_coding', '4313',  'ENSG00000087245'),
('CXCR4',  'C-X-C Motif Chemokine Receptor 4',               '2',  136871844,136875035,'-', 'Chemokine receptor; breast cancer metastasis to bone',            'protein_coding', '7852',  'ENSG00000121966'),
('CXCL12', 'C-X-C Motif Chemokine Ligand 12 (SDF-1)',        '10', 44865601, 44880545, '+', 'CXCR4 ligand; metastasis homing signal',                          'protein_coding', '6387',  'ENSG00000107562'),
('KRT5',   'Keratin 5',                                       '12', 52878779, 52887244, '+', 'Basal cytokeratin; marker for basal-like breast cancer',          'protein_coding', '3852',  'ENSG00000186081'),
('KRT14',  'Keratin 14',                                      '17', 39743434, 39750819, '-', 'Basal cytokeratin; myoepithelial marker',                         'protein_coding', '3861',  'ENSG00000186832'),
('KRT18',  'Keratin 18',                                      '12', 53011044, 53021428, '-', 'Luminal cytokeratin; luminal subtype marker',                     'protein_coding', '3875',  'ENSG00000111057'),
('KRT19',  'Keratin 19',                                      '17', 39744892, 39748730, '-', 'Luminal cytokeratin; used as circulating tumor cell marker',      'protein_coding', '3880',  'ENSG00000171345'),
('EPCAM',  'Epithelial Cell Adhesion Molecule',               '2',  47378058, 47400202, '+', 'Epithelial adhesion; cancer stem cell marker',                    'protein_coding', '4072',  'ENSG00000119888'),
('CD44',   'CD44 Molecule',                                   '11', 35138758, 35229705, '-', 'Cell surface glycoprotein; cancer stem cell marker',              'protein_coding', '960',   'ENSG00000026508'),
('CD24',   'CD24 Molecule',                                   '6',  107466362,107476591,'-', 'Cell surface protein; differentiation marker',                    'protein_coding', '100133805','ENSG00000272398'),
('ALDH1A1','Aldehyde Dehydrogenase 1 Family Member A1',       '9',  75584519, 75628880, '-', 'Cancer stem cell marker; ALDH activity assay',                   'protein_coding', '216',   'ENSG00000165092'),
('SOX2',   'SRY-Box Transcription Factor 2',                  '3',  181711925,181714436,'+', 'Stemness factor; breast cancer stem cells',                       'protein_coding', '6657',  'ENSG00000181449'),
('NANOG',  'Nanog Homeobox',                                  '12', 7786304,  7797503,  '+', 'Pluripotency factor; cancer stem cell maintenance',               'protein_coding', '79923', 'ENSG00000111704'),
('OCT4',   'POU Class 5 Homeobox 1 (POU5F1)',                 '6',  31244985, 31259166, '-', 'Pluripotency transcription factor; stem cell marker',             'protein_coding', '5460',  'ENSG00000204531'),
('KLF4',   'Kruppel Like Factor 4',                           '9',  107255617,107261534,'+', 'Transcription factor; reprogramming and stemness',                'protein_coding', '9314',  'ENSG00000136826'),
('TERT',   'Telomerase Reverse Transcriptase',                '5',  1253262,  1295047,  '+', 'Telomerase; reactivated in cancer cells',                         'protein_coding', '7015',  'ENSG00000164362'),
('DICER1', 'Dicer 1, Ribonuclease III',                       '14', 95070258, 95170745, '+', 'miRNA biogenesis; tumor suppressor role',                         'protein_coding', '23405', 'ENSG00000100697'),
('DROSHA', 'Drosha Ribonuclease III',                         '5',  31411870, 31479939, '+', 'miRNA processing; nuclear RNase III',                             'protein_coding', '29102', 'ENSG00000113296'),
('AGO2',   'Argonaute RISC Catalytic Component 2',            '8',  141543877,141634799,'+', 'miRNA effector; RISC complex core component',                     'protein_coding', '27161', 'ENSG00000123908'),
('DNMT1',  'DNA Methyltransferase 1',                         '19', 10133346, 10231286, '-', 'DNA methylation maintenance; epigenetic regulation',              'protein_coding', '1786',  'ENSG00000130816'),
('DNMT3A', 'DNA Methyltransferase 3 Alpha',                   '2',  25227847, 25342590, '+', 'De novo DNA methyltransferase',                                   'protein_coding', '1788',  'ENSG00000119772'),
('EZH2',   'Enhancer Of Zeste 2 Polycomb Repressive Complex 2 Subunit','7',148503688,148581696,'+','H3K27me3 methyltransferase; oncogenic epigenetic regulator','protein_coding','2146','ENSG00000106462'),
('HDAC1',  'Histone Deacetylase 1',                           '1',  32757170, 32779933, '+', 'Histone deacetylase; transcriptional repressor',                  'protein_coding', '3065',  'ENSG00000116478'),
('BRD4',   'Bromodomain Containing 4',                        '19', 15176264, 15283665, '+', 'BET bromodomain; transcription regulation; drug target',          'protein_coding', '23476', 'ENSG00000141867'),
('PARP1',  'Poly(ADP-Ribose) Polymerase 1',                   '1',  226360139,226405948,'+', 'DNA repair enzyme; PARP inhibitor target in BRCA-mutant cancer',  'protein_coding', '142',   'ENSG00000143799'),
('TOP2A',  'DNA Topoisomerase II Alpha',                      '17', 38543838, 38597979, '+', 'Topoisomerase; anthracycline target; amplified in HER2+ cancer',  'protein_coding', '7153',  'ENSG00000131747'),
('PCNA',   'Proliferating Cell Nuclear Antigen',              '20', 5117148,  5120751,  '+', 'DNA replication clamp; proliferation marker',                     'protein_coding', '5111',  'ENSG00000132646'),
('MKI67',  'Marker Of Proliferation Ki-67',                   '10', 127766000,127818585,'+', 'Ki-67; proliferation index in breast cancer grading',             'protein_coding', '4288',  'ENSG00000148773'),
('CYP19A1','Cytochrome P450 Family 19 Subfamily A Member 1 (Aromatase)','15',51208195,51338597,'+','Estrogen biosynthesis; aromatase inhibitor target',         'protein_coding', '1588',  'ENSG00000137869'),
('SRC',    'SRC Proto-Oncogene, Non-Receptor Tyrosine Kinase','20', 37344891, 37435498, '-', 'Tyrosine kinase; downstream of integrins and receptors',          'protein_coding', '6714',  'ENSG00000197122'),
('FAK1',   'Focal Adhesion Kinase 1 (PTK2)',                  '8',  141692069,141866765,'-', 'Focal adhesion kinase; invasion and migration',                   'protein_coding', '5747',  'ENSG00000169398'),
('IGF1R',  'Insulin Like Growth Factor 1 Receptor',           '15', 98948703, 99241729, '-', 'IGF1 receptor; growth and survival signaling',                    'protein_coding', '3480',  'ENSG00000140443'),
('INSR',   'Insulin Receptor',                                '19', 7112386,  7294484,  '+', 'Insulin receptor; metabolic and growth signaling',                'protein_coding', '3643',  'ENSG00000171105'),
('FGFR1',  'Fibroblast Growth Factor Receptor 1',             '8',  38268655, 38326352, '+', 'FGF receptor 1; amplified in luminal B breast cancer',            'protein_coding', '2260',  'ENSG00000077782'),
('FGFR2',  'Fibroblast Growth Factor Receptor 2',             '10', 121478334,121598457,'-', 'FGF receptor 2; germline SNPs associated with breast cancer risk','protein_coding', '2263',  'ENSG00000066468'),
('PDGFRA', 'Platelet Derived Growth Factor Receptor Alpha',   '4',  54229488, 54298243, '+', 'PDGF receptor; activated in some breast cancer subtypes',         'protein_coding', '5156',  'ENSG00000134853'),
('MET',    'MET Proto-Oncogene, Receptor Tyrosine Kinase',    '7',  116672195,116798386,'+', 'HGF receptor; invasive growth; poor prognosis marker',            'protein_coding', '4233',  'ENSG00000105976'),
('RET',    'RET Proto-Oncogene',                              '10', 43077069, 43130351, '+', 'RET receptor; rearrangements in some breast cancers',             'protein_coding', '5979',  'ENSG00000165731');

-- ------------------------------------------------------------
-- Sample Records (virtual patients)
-- ------------------------------------------------------------
INSERT INTO samples (sample_name, sample_type, patient_id, tissue_type, cancer_stage, age, gender, source) VALUES
('TCGA-BH-A0BZ-01A','tumor',  'TCGA-BH-A0BZ','breast','II',  52,'F','TCGA - Simulated'),
('TCGA-BH-A0BZ-11A','normal', 'TCGA-BH-A0BZ','breast', NULL, 52,'F','TCGA - Simulated'),
('TCGA-A7-A0CD-01A','tumor',  'TCGA-A7-A0CD','breast','III', 61,'F','TCGA - Simulated'),
('TCGA-A7-A0CD-11A','normal', 'TCGA-A7-A0CD','breast', NULL, 61,'F','TCGA - Simulated'),
('TCGA-AN-A046-01A','tumor',  'TCGA-AN-A046','breast','I',   44,'F','TCGA - Simulated'),
('TCGA-AN-A046-11A','normal', 'TCGA-AN-A046','breast', NULL, 44,'F','TCGA - Simulated'),
('TCGA-AR-A1AI-01A','tumor',  'TCGA-AR-A1AI','breast','II',  58,'F','TCGA - Simulated'),
('TCGA-AR-A1AI-11A','normal', 'TCGA-AR-A1AI','breast', NULL, 58,'F','TCGA - Simulated'),
('TCGA-B6-A0RL-01A','tumor',  'TCGA-B6-A0RL','breast','IV',  67,'F','TCGA - Simulated'),
('TCGA-B6-A0RL-11A','normal', 'TCGA-B6-A0RL','breast', NULL, 67,'F','TCGA - Simulated');

-- ------------------------------------------------------------
-- Expression Data
-- (normal_expression TPM, cancer_expression TPM, log2FC, pvalue)
-- ------------------------------------------------------------
INSERT INTO expression_data (gene_id, tissue_type, normal_expression, cancer_expression, fold_change, log2_fold_change, p_value, adj_p_value, is_significant, regulation)
SELECT g.gene_id, 'breast', e.norm, e.canc, e.canc/e.norm,
       LOG2(e.canc/e.norm), e.pval, e.pval*1.5,
       IF(e.pval < 0.05, 1, 0),
       IF(LOG2(e.canc/e.norm) > 1, 'up', IF(LOG2(e.canc/e.norm) < -1,'down','unchanged'))
FROM genes g
JOIN (SELECT 'TP53'   sym, 45.2,  12.8,  0.0001 UNION ALL
      SELECT 'BRCA1',        38.1,  9.4,   0.0001 UNION ALL
      SELECT 'BRCA2',        22.6,  7.3,   0.0002 UNION ALL
      SELECT 'ESR1',         128.4, 412.7, 0.0001 UNION ALL
      SELECT 'PGR',          89.3,  278.5, 0.0001 UNION ALL
      SELECT 'ERBB2',        12.1,  189.6, 0.0001 UNION ALL
      SELECT 'EGFR',         8.4,   67.3,  0.0001 UNION ALL
      SELECT 'MYC',          15.6,  98.4,  0.0001 UNION ALL
      SELECT 'PIK3CA',       32.1,  87.6,  0.0001 UNION ALL
      SELECT 'AKT1',         28.7,  75.3,  0.0002 UNION ALL
      SELECT 'PTEN',         52.3,  14.7,  0.0001 UNION ALL
      SELECT 'CDH1',         234.5, 56.8,  0.0001 UNION ALL
      SELECT 'VEGFA',        18.9,  142.3, 0.0001 UNION ALL
      SELECT 'MMP9',         5.2,   78.6,  0.0001 UNION ALL
      SELECT 'CCND1',        21.4,  167.8, 0.0001 UNION ALL
      SELECT 'CDK4',         18.3,  65.4,  0.0003 UNION ALL
      SELECT 'CDK6',         14.7,  52.1,  0.0004 UNION ALL
      SELECT 'RB1',          67.8,  23.4,  0.0001 UNION ALL
      SELECT 'KRAS',         24.3,  38.7,  0.0210 UNION ALL
      SELECT 'HRAS',         12.1,  28.4,  0.0150 UNION ALL
      SELECT 'NRAS',         18.7,  31.2,  0.0430 UNION ALL
      SELECT 'BRAF',         22.4,  41.7,  0.0180 UNION ALL
      SELECT 'MAP2K1',       31.2,  58.9,  0.0120 UNION ALL
      SELECT 'MAPK1',        45.6,  82.3,  0.0090 UNION ALL
      SELECT 'MTOR',         38.4,  71.6,  0.0070 UNION ALL
      SELECT 'TSC1',         28.9,  15.3,  0.0240 UNION ALL
      SELECT 'TSC2',         31.4,  17.8,  0.0310 UNION ALL
      SELECT 'STAT3',        22.7,  89.4,  0.0001 UNION ALL
      SELECT 'JAK2',         19.3,  54.7,  0.0020 UNION ALL
      SELECT 'IL6',          4.8,   67.2,  0.0001 UNION ALL
      SELECT 'TNF',          8.3,   42.1,  0.0030 UNION ALL
      SELECT 'TGFB1',        34.6,  78.9,  0.0040 UNION ALL
      SELECT 'NOTCH1',       28.4,  67.8,  0.0060 UNION ALL
      SELECT 'WNT5A',        18.7,  52.3,  0.0080 UNION ALL
      SELECT 'CTNNB1',       42.1,  89.6,  0.0020 UNION ALL
      SELECT 'APC',          67.3,  23.1,  0.0001 UNION ALL
      SELECT 'CASP8',        45.2,  18.7,  0.0050 UNION ALL
      SELECT 'BCL2',         12.4,  78.3,  0.0001 UNION ALL
      SELECT 'BCL2L1',       18.7,  64.5,  0.0020 UNION ALL
      SELECT 'BAX',          38.9,  14.2,  0.0030 UNION ALL
      SELECT 'MDM2',         14.3,  67.8,  0.0001 UNION ALL
      SELECT 'CDKN1A',       52.4,  23.1,  0.0040 UNION ALL
      SELECT 'CDKN2A',       42.7,  8.3,   0.0001 UNION ALL
      SELECT 'E2F1',         18.9,  72.4,  0.0001 UNION ALL
      SELECT 'FOXM1',        12.3,  89.6,  0.0001 UNION ALL
      SELECT 'AURKA',        14.7,  112.3, 0.0001 UNION ALL
      SELECT 'AURKB',        12.1,  98.7,  0.0001 UNION ALL
      SELECT 'PLK1',         16.4,  134.5, 0.0001 UNION ALL
      SELECT 'CHEK1',        28.3,  67.4,  0.0020 UNION ALL
      SELECT 'CHEK2',        32.1,  14.7,  0.0050 UNION ALL
      SELECT 'ATM',          48.7,  21.3,  0.0010 UNION ALL
      SELECT 'RAD51',        24.3,  67.8,  0.0020 UNION ALL
      SELECT 'PALB2',        18.9,  8.4,   0.0080 UNION ALL
      SELECT 'FANCA',        22.4,  11.7,  0.0120 UNION ALL
      SELECT 'NF1',          38.1,  12.4,  0.0030 UNION ALL
      SELECT 'ARID1A',       42.3,  18.9,  0.0040 UNION ALL
      SELECT 'KMT2C',        28.7,  14.3,  0.0090 UNION ALL
      SELECT 'GATA3',        78.4,  198.7, 0.0001 UNION ALL
      SELECT 'FOXA1',        67.3,  178.4, 0.0001 UNION ALL
      SELECT 'RUNX2',        12.4,  56.7,  0.0020 UNION ALL
      SELECT 'TWIST1',       8.3,   67.4,  0.0001 UNION ALL
      SELECT 'SNAI1',        14.7,  89.3,  0.0001 UNION ALL
      SELECT 'ZEB1',         18.4,  78.6,  0.0001 UNION ALL
      SELECT 'VIM',          42.1,  167.8, 0.0001 UNION ALL
      SELECT 'FN1',          34.7,  123.4, 0.0010 UNION ALL
      SELECT 'MMP2',         8.4,   67.3,  0.0020 UNION ALL
      SELECT 'CXCR4',        12.3,  78.4,  0.0010 UNION ALL
      SELECT 'CXCL12',       28.4,  12.7,  0.0030 UNION ALL
      SELECT 'KRT5',         34.7,  89.3,  0.0040 UNION ALL
      SELECT 'KRT14',        42.1,  112.4, 0.0020 UNION ALL
      SELECT 'KRT18',        234.5, 89.3,  0.0030 UNION ALL
      SELECT 'KRT19',        198.7, 78.4,  0.0040 UNION ALL
      SELECT 'EPCAM',        178.4, 89.7,  0.0050 UNION ALL
      SELECT 'CD44',         28.4,  134.7, 0.0001 UNION ALL
      SELECT 'CD24',         42.3,  18.7,  0.0060 UNION ALL
      SELECT 'ALDH1A1',      18.7,  67.4,  0.0020 UNION ALL
      SELECT 'SOX2',         8.4,   56.7,  0.0030 UNION ALL
      SELECT 'NANOG',        6.3,   42.1,  0.0040 UNION ALL
      SELECT 'OCT4',         4.7,   38.4,  0.0050 UNION ALL
      SELECT 'KLF4',         18.4,  52.3,  0.0060 UNION ALL
      SELECT 'TERT',         4.2,   67.8,  0.0001 UNION ALL
      SELECT 'DICER1',       42.1,  18.7,  0.0070 UNION ALL
      SELECT 'DROSHA',       34.7,  21.3,  0.0120 UNION ALL
      SELECT 'AGO2',         38.4,  67.8,  0.0090 UNION ALL
      SELECT 'DNMT1',        28.7,  89.4,  0.0010 UNION ALL
      SELECT 'DNMT3A',       22.4,  14.7,  0.0200 UNION ALL
      SELECT 'EZH2',         18.7,  134.5, 0.0001 UNION ALL
      SELECT 'HDAC1',        42.3,  89.7,  0.0030 UNION ALL
      SELECT 'BRD4',         34.1,  78.4,  0.0040 UNION ALL
      SELECT 'PARP1',        38.7,  89.3,  0.0050 UNION ALL
      SELECT 'TOP2A',        12.4,  167.8, 0.0001 UNION ALL
      SELECT 'PCNA',         34.7,  123.4, 0.0001 UNION ALL
      SELECT 'MKI67',        8.4,   134.7, 0.0001 UNION ALL
      SELECT 'CYP19A1',      18.7,  67.4,  0.0020 UNION ALL
      SELECT 'SRC',          28.4,  78.3,  0.0030 UNION ALL
      SELECT 'FAK1',         22.1,  67.8,  0.0040 UNION ALL
      SELECT 'IGF1R',        42.3,  89.7,  0.0020 UNION ALL
      SELECT 'INSR',         38.7,  67.4,  0.0060 UNION ALL
      SELECT 'FGFR1',        14.7,  78.9,  0.0010 UNION ALL
      SELECT 'FGFR2',        28.4,  12.7,  0.0040 UNION ALL
      SELECT 'PDGFRA',       18.7,  42.3,  0.0080 UNION ALL
      SELECT 'MET',          12.4,  67.8,  0.0020 UNION ALL
      SELECT 'RET',          8.3,   34.7,  0.0060 ) AS e(sym, norm, canc, pval)
ON g.gene_symbol = e.sym;

-- Update fold_change and adj_p_value calculations
UPDATE expression_data SET
    fold_change      = cancer_expression / normal_expression,
    log2_fold_change = LOG2(cancer_expression / normal_expression),
    adj_p_value      = LEAST(p_value * 1.5, 1.0),
    is_significant   = IF(p_value < 0.05, 1, 0),
    regulation       = IF(LOG2(cancer_expression/normal_expression) > 1, 'up',
                         IF(LOG2(cancer_expression/normal_expression) < -1, 'down', 'unchanged'));

-- ------------------------------------------------------------
-- BLAST Sequences (representative partial sequences)
-- ------------------------------------------------------------
INSERT INTO blast_sequences (gene_id, sequence, seq_type, species, seq_length, gc_content, accession)
SELECT g.gene_id, s.seq, 'mRNA', 'Homo sapiens', LENGTH(s.seq),
       ROUND((LENGTH(s.seq) - LENGTH(REPLACE(REPLACE(s.seq,'G',''),'C',''))) / LENGTH(s.seq) * 100, 2),
       s.acc
FROM genes g
JOIN (
  SELECT 'TP53'  sym,'NM_000546' acc,'ATGGAGGAGCCGCAGTCAGATCCTAGCGTTGAATCAAACGGCCAGCTGTGTTATCTCCTAGGTTGGCTCTGACTTCAACCAGGGGGCCGTGATGGCCATCTACAAGCAGTCACAGCACATGACGGAGGTTGTGAGGCGCTGCCCCCACCATGAGCGCTGCTCAGATAGCGATGGTCTGGCCCCTCCTCAGCATCTTATCCGAGTGGAAGGAAATTTGCGTGTGGAGTATTTGGATGACAGAAACACTTTTCGACATAGTGTGGTGGTGCCCTATGAGCCGCCTGAGGTTGGCTCTGACTGTACCACCATCCACTACAACTACATGTGTAACAGTTCCTGCATGGGCGGCATGAACCGGAGGCCCATCCTCACCATCATCACACTGGAAGACTCCAGTGGTAATCTACTGGGACGGAACAGCTTTGAGGTGCGTGTTTGTGCCTGTCCTGGGAGAGACCGGCGCACAGAGGAAGAGAATCTCCGCAAGAAAGGGGAGCCTCACCACGAGCTGCCCCCAGGGAGCACTAAGCGAGCACTGCCCAACAACACCAGCTCCTCTCCCCAGCCAAAGAAGAAACCACTGGATGGAGAATATTTCACCCTTCAGATCCGTGGGCGTGAGCGCTTCGAGATGTTCCGAGAGCTGAATGAGGCCTTGGAACTCAAGCCGTACTCCAGTGTTACCTGCACCTACTTCCCATCCCAGCAGCTTCAAGATGGCCAGTGGAGCTGGGTTTCTCAGAGGCATGATGGAGCTAAAGGACTGTGATGCTGTAAGCAAAGAATGTCCCAAGGACATCGTGGTGGAGGAGCCAGAGCAGATTGAGCAGCTTCAGCAGCAGCTGGAGGTCCAGCAGCAGCAGCAGCAGGAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG' seq
  UNION ALL SELECT 'BRCA1','NM_007294','ATGGATTTATCTGCTCTTCGCGTTGAAGAAGTACAAAATGTCATTAATGCTATGCAGAAAATCTTAGAGTGTCCCATCTGTCTGGAGTTGATCAAGGAACCTGTCTCCACAAAGTGTGACCACATACTTTGGCAGACCTATCTTCCGTGAAACTTGTCACACTGAACTATTTCCATTATTTGTATGAGTAAAAGTAGCATTGTTATTTACAGAACATTTTTCAACCTGTCTCCTAAGTTATCAGAAAGGAAATTTAAGGATTATTTCATCACTGATAAACCTTGTGGTTGTGTGCAGATCCAGATGGAGCAGATTAGAAATCATGAAAGCATTTCAGAAATCCCCAAGCAGAAAGCAGAATTAGAAATGATGTTAAAGAGTAAGGTCAAAGCTAAGGGACAGCAGCAGCAGCAAGAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG'  seq
  UNION ALL SELECT 'BRCA2','NM_000059','ATGCCTATTGGATCCAAAGAGAGGCCAACATTTTTTGAAATTTTTAAGACACGCTGCAACAAAGCAGATTTAGGACCAATAATATTTTGCTCCTCAGAAAGAAAGAAAGAGAGAGACTTAATCCAGAATTTCAGACAGTTTTTAAACAGCACAGCAGATGGCAAAGCTTTGCAGCAAGGCAACTTTCTCAGAAAGAGTCCAACAGCAAAGAGCAGAAGCAGGAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG'  seq
  UNION ALL SELECT 'ESR1','NM_000125','ATGACCATGACCCTCCACACCAAAGCATCTGGGATGGCCCTACTGCATCAGATCCGAAAGCCACATCCCTGGCAGCGGCAGCAGCAGCAGCAGCAAGCAGCAGCAGCAGCAGCAGCAGCAGCAAGGCGGCCCAGCCCCCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGTCCCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAACAGCAGCAGCAGCAGCAGCAGCAGCAACAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGGAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG'  seq
  UNION ALL SELECT 'ERBB2','NM_004448','ATGGAGCTGGCGGCCTTGTGCCGCTGGGGGCTCCTCCTCGCCCTCTTGCCCTTGTGGCCAGGGTCCCAGCTGGAGGAGCAGCGGCCCAGCGAGCAGGAGCCCTGGAGCCAGGAAGCCCCTGTGGGCCAGCCCAGCAGAAGCTGCTGGACCAGCATGACCTGGAGCCCTTGGTGCAGCCCAAGCTGCTCCCAGACAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG'  seq
  UNION ALL SELECT 'EGFR','NM_005228','ATGCGACCCTCCGGGACGGCCGGGGCAGCGCTCCTGGCGCTGCTGGCTGCGCTCTGCCCGGCGAGTCGGGCTCTGGAGGAAAAGAAAGTTTGCCAAGGCACGAGTAACAAGCTCACGCAGTTGGGCACTTTTGAAGATCATTTTCTCAGCCCAAAGAGCATCGCAGTGGGGGGCACGGTCAAGATCCTGGAGCAGTTCCACCCTGGCAGCATGTGGTCAGGGCTTGGAGTCCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG'  seq
  UNION ALL SELECT 'MYC','NM_002467','ATGCCCCTCAACGTTAGCTTCACCAACAGGAACTATGACCTCGACTACGACTCGGTGCAGCCGTATTTCTACTGCGACGAGGAGGAGAACTTCTACCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG' seq
  UNION ALL SELECT 'PIK3CA','NM_006218','ATGCAGCACCGTCCAGAATCCAAGAGCAATGAATCCTGGAAAATCCCCAGAAGTCAGCCCAGAAGCCCAGCCACAGTTCAAGACCAAGCGAAAGAAAGAAAGAGAAGCAGTCAGGACTCCAGTTTGTGAATGATGCAGAAGAATCTGTGAAAGAAAAGGATGATGATGAAGACGATCAAGAAGAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG' seq
  UNION ALL SELECT 'MKI67','NM_001145966','ATGTCTCCAGCCAGTTTCCCAGAAAGAAATCAGAATCCAGGAAAAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAGAGAAAG' seq
  UNION ALL SELECT 'PARP1','NM_001618','ATGGCGGAGTCTTCGGATAAGCCGGCGGCCGCAGCCATGGAGAACAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAG' seq
) AS s ON g.gene_symbol = s.sym;
