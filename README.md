# CLL DIA-MS proteomics — PRIDE PXD022216 + PXD022198 (Meier-Abt et al., Blood 2021)

This directory documents and retrieves the two mass spectrometry deposits behind
Meier-Abt et al., "The protein landscape of chronic lymphocytic leukemia",
*Blood* 138(24):2514–2525 (2021). Both are hosted by the PRIDE Archive at
EMBL-EBI: **PXD022216** holds the Bruker timsTOF Pro diaPASEF acquisitions
(50 `.d.zip` archives) and **PXD022198** holds the Thermo Orbitrap Fusion Lumos
acquisitions (135 `.raw` files). All 194 deposited files are documented and
checksummed here, grouped into three cumulative download depths so the
analysis-ready tables can be fetched without committing to 584 GiB of raw
acquisitions. The article's supplementary tables are analysis results published
by the journal, not deposited data, and are deliberately out of scope.

## What the source study found

The study asked how recurrent genetic lesions in chronic lymphocytic leukemia
translate into protein expression, a layer that earlier CLL work had covered
only in small patient sets. The authors profiled the proteome of 117 CLL patient
samples by data-independent-acquisition mass spectrometry and integrated it with
genomic, transcriptomic, ex vivo drug-response and clinical-outcome data. They
report that trisomy 12 and IGHV mutational status are the dominant determinants
of proteome variation (1055 and 542 differentially expressed proteins at 5%
FDR), with further effects from mutated SF3B1, trisomy 19, del(17)(p13),
del(11)(q22.3), mutated DDX3X and MED12; that trisomy 12 CLL shows limited
protein abundance buffering together with an upregulated complex in
BCR/AKT/MAPK/PI3K signaling; and that STAT2 protein expression is associated
with response to kinase inhibitors including BTK and MEK inhibitors. The files
in this directory are the primary measurements from which those protein
abundances were derived: the raw acquisitions of both MS platforms, and the
Spectronaut search output that turned them into protein and peptide quantities.

## Experimental setup

| Field | Value |
| --- | --- |
| Organism / sample type | *Homo sapiens*, peripheral blood. Main cohort batch 1 (samples 1–49): thawed mononuclear cells; batch 2 (samples 50–91): CD19+ CLL cells selected from mononuclear cells by MACS; additional cohort batch 3 (samples 92–117): 100 000 FACS-sorted CD19+ CD5+ light-chain-restricted cells per sample. `derived:` the annotation file resolves which acquisition belongs to which batch — batch 1 = the 49 `20191016_*` runs, batch 2 = the 42 `20210107_*_CD19selected_*` runs, batch 3 = the 26 `20201112_*_screen2_*` runs |
| Conditions / comparison groups | Not treatment arms — patient samples stratified post hoc by genetic lesion. The paper's primary contrasts are trisomy 12 and IGHV mutational status; further tested: mutated SF3B1, trisomy 19, del(17)(p13), del(11)(q22.3), mutated DDX3X, mutated MED12 |
| Biological replicates | 117 CLL patient samples in the study overall. The PXD022198 record states 117 samples profiled (139 files deposited); the PXD022216 record states 49 samples (55 files deposited, 50 of them raw acquisitions) and notes that one outlier was excluded from downstream analysis for a singularly large proportion of missing values |
| Technical replicates | None among the deposited sample runs. `derived:` read from both annotation files. `PXD022198/Annotation_file.csv` lists 117 sample runs against 117 distinct Patient IDs and 117 distinct Sample IDs, no identifier reused across its two cohort tables; `PXD022216/Annotation_file_timsTOF.txt` lists 50 runs against 50 distinct Patient IDs, Sample IDs and pseudonyms. The `_rep` suffix on five batch-1 run names is part of the acquisition file name, not a replicate marker |
| Instrument / platform | PXD022216: Bruker timsTOF Pro coupled to a Bruker nanoElute, PicoFrit column (75 µm × 450 mm, Reprosil C18 Aq 1.9 µm), 60 °C, 400 nL/min, 2→24% B over 100 min. PXD022198: Thermo Orbitrap Fusion Lumos with a Digital PicoView source, coupled to a Waters M-Class UPLC; MZ Symmetry C18 trap then nanoEase MZ C18 HSS T3 (75 µm × 250 mm), 300 nL/min, 8→22% B in 112 min, 32% in 8 min, 95% in 5 min; Tune Plus 2.1 |
| Assay / protocol | Lyophilized cell pellets resuspended in 8 M urea / 100 mM ammonium hydrogen carbonate, VialTweeter sonication, BCA or Qubit protein assay, Benzonase, TCEP reduction, iodoacetamide alkylation, trypsin 1:50 overnight at 37 °C, C18 desalting, Biognosys iRT peptides spiked before injection. PXD022216: standard diaPASEF (trapped-ion-mobility DIA), 1 µL / 100 ng on column. PXD022198: DDA and DIA, HCD at 30% (DDA) / 28% (DIA) normalized collision energy, MS1 resolution 120 000 and MS2 30 000, MS1 350–1500 *m/z*, MS2 200–1800 *m/z* for DIA, 4 µL / 200 ng on column |
| Processing pipeline | Spectronaut library building and DIA search, then R. PXD022216: direct (DIA-only) library, searched against the SwissProt-reviewed human UniProt subset version 2020-01-01, 20 367 entries, decoys by "mutation". PXD022198: hybrid (DDA+DIA) library, searched against SwissProt-reviewed human UniProt version 2019-07-09, 20 913 entries, decoys by sequence reversal; trypsin, max. 2 missed cleavages, carbamidomethyl (C) fixed, acetyl (protein N-term) and oxidation (M) variable, b/y ions, 1% FDR at peptide and protein level, quantification restricted to proteins with ≥2 proteotypic peptides. Downstream: background correction, scaling and variance-stabilizing transformation, ≥50% completeness filter |
| Software versions | Spectronaut v14.4 (PXD022216); Spectronaut v13.4 for PXD022198 main-cohort batch 1 and v14.5 for batch 2 and the FACS-sorted batch 3; R 3.6.0 with Bioconductor DEP; downstream analysis used proDA, limma (incl. CAMERA), DESeq2, DEXSeq, sva/ComBat and coxph. `derived:` the PXD022216 search database is confirmed from the data — every one of the 786 266 rows of the exported spectral library carries `FASTAName = uniprot_sprot_2020-01-01_HUMAN` and `Database = sp` |

The two deposits are the same study measured on two platforms, cross-linked to
each other upstream, and they are *not* independent replicates of one another:
PXD022216 is a 49-sample diaPASEF subset, PXD022198 covers the 117-sample
cohort on the Lumos. Analysis code and Rmarkdown workflows for the published
figures live outside these deposits, at
`https://github.com/Huber-group-EMBL/CLLproteomics` — a URL quoted from the
article's data-sharing statement and UNVERIFIED: not fetched during this
session. The DNA-sequencing, RNA-sequencing and ex vivo drug-response layers
integrated in the paper are **not** in these deposits; the article states they
were generated previously and are distributed in the Bioconductor data package
`BloodCancerMultiOmics2017`. This directory does not cover them.

## What is here

The deposits hold three kinds of record. First, vendor-native raw acquisitions:
zipped Bruker `.d` folders for the timsTOF and Thermo `.raw` files for the
Lumos — the primary measurements. Second, Spectronaut search output:
peptide/precursor- and protein-level long-format reports and per-batch
protein-quantification reports, plus one spectral library export and one `.sne`
Spectronaut session archive. Third, one experimental-design annotation file per
deposit, mapping MS run name to patient sample.

Depth `default` has been retrieved and verified: all 7 files are on disk, each
checked against its publisher SHA-1 before its pin was written. All 187
`raw`-depth rows are planned, with `bytes`, `sha256` and `pinned_date` all
`PENDING`, and none of those files is held locally.

Files are grouped into three download depths. `./DOWNLOAD.sh` with no argument
fetches `default`; pass `supplementary` or `raw` to go deeper. Depth is
cumulative, so `raw` fetches everything.

The `Files` and `Total size` columns are what each depth **adds**, matching the
per-depth row counts in `MANIFEST.tsv`. Because depth is cumulative, the
cumulative totals are 7 files / 552.2 MiB at `default`, the same 7 at
`supplementary`, and all 194 files / 583.9 GiB at `raw`.

| Depth | Contents | Files | Total size | Downloaded here |
| --- | --- | --- | --- | --- |
| `default` | the analysis-ready tables: the Spectronaut precursor and protein reports, the three per-batch protein-quantification reports, and both annotation files | 7 | 552.2 MiB | **yes**, 2026-08-20 |
| `supplementary` | supplementary and secondary files. Neither deposit contains any, so this depth adds nothing and resolves to the same 7 files as `default` | 0 | 0 B | **yes** — identical to `default` |
| `raw` | the bulk inputs: 185 raw MS acquisitions, the exported Spectronaut spectral library, and the 24.2 GiB `.sne` session archive | 187 | 583.3 GiB | no — `./DOWNLOAD.sh raw` |

Sizes are the byte counts published in the PRIDE file records, read from the
saved API artifacts under `provenance/upstream/`. They are upstream claims, not
local measurements — `MANIFEST.tsv`'s `bytes` column holds a local observation
and is `PENDING` until a file is retrieved.

```
2021_meier-abt_human_blood_cll__ms-proteomics-rna-seq-genomics_ds/
  README.md                     this file
  PROVENANCE.md                 citation, license, per-file descriptions, integrity record
  MANIFEST.tsv                  authoritative paths, depths, pins, upstream hashes, URLs (194 rows)
  DOWNLOAD.sh                   retrieve and verify; --help for options
  TEST_DOWNLOAD.sh              check that DOWNLOAD.sh and these documents are correct
  .gitignore                    keeps the data files out of version control
  provenance/upstream/          saved upstream metadata artifacts (checksum evidence)

  PXD022216/                    timsTOF Pro, diaPASEF — 55 files
    PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv           1 file   455.6 MiB  default
    PXD022216/20200727_104510_200725_cll_diaPASEF_direct_Report_Protein_long.tsv           1 file    55.1 MiB  default
    PXD022216/Annotation_file_timsTOF.txt                                                  1 file     5.1 KiB  default
    PXD022216/200723_CLL_library_direct.tsv                                                1 file   295.6 MiB  raw
    PXD022216/20200727_105729_200725_cll_diaPASEF_direct.sne                               1 file    24.2 GiB  raw
    PXD022216/fmeierab_T190525_CLL_diaPASEF_*.d.zip                                       50 files  218.1 GiB  raw

  PXD022198/                    Orbitrap Fusion Lumos — 139 files
    PXD022198/20201112_p3254_o23219_CLLsample_library_ProteinQuant_Report.csv               1 file    11.4 MiB  default
    PXD022198/20201207_p3254_o20368_hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv  1 file  12.3 MiB  default
    PXD022198/20210117_p3254_o23722_CD19selected_Library_ProteinQuant_Report.csv            1 file    17.8 MiB  default
    PXD022198/Annotation_file.csv                                                          1 file    17.6 KiB  default
    PXD022198/20191016_0??_S*_CLL_*.raw                                                   49 files  135.5 GiB  raw
    PXD022198/20191016_0?_L?*.raw                                                          6 files    3.8 GiB  raw
    PXD022198/20201112_*_CLL_screen2_[0-9]*_Diseased.raw                                  26 files   66.8 GiB  raw
    PXD022198/20201112_*_CLL_screen2_Pool*_Diseased.raw                                    6 files    2.8 GiB  raw
    PXD022198/20210107_*_CLL_CD19selected_[0-9]*_Diseased.raw                             42 files  128.1 GiB  raw
    PXD022198/20210107_*_CLL_CD19selected_Pool*.raw                                        6 files    3.7 GiB  raw
```

## Data statistics

Computed from the downloaded files, not taken from the publication. Cells is
samples x feature rows; completeness is non-missing cells / cells. All five
quantitative files are Spectronaut **long**-format exports — one row per
sample-feature observation — so cells is (unique runs x unique features) and
non-missing is the number of observed pairs.

| File | Level | Samples | Feature rows | Unique features | Cells | Completeness | Unique proteins |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv` | precursor | 50 | 2 188 036 | 59 484 | 2 974 200 | 73.57% | 5 196 |
| `PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv` | peptidoform | 50 | 1 939 621 | 51 419 | 2 570 950 | 75.44% | 5 196 |
| `PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv` | peptide (stripped) | 50 | 1 904 963 | 49 691 | 2 484 550 | 76.67% | 5 196 |
| `PXD022216/20200727_104510_200725_cll_diaPASEF_direct_Report_Protein_long.tsv` | protein | 50 | 396 500 | 5 199 | 259 950 | 92.58% | 5 199 (the feature itself) |
| `PXD022198/20201207_p3254_o20368_hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv` | protein | 50 | 209 543 | 4 452 | 222 600 | 76.39% | 4 452 (the feature itself) |
| `PXD022198/20210117_p3254_o23722_CD19selected_Library_ProteinQuant_Report.csv` | protein | 53 | 255 533 | 5 113 | 270 989 | 76.29% | 5 113 (the feature itself) |
| `PXD022198/20201112_p3254_o23219_CLLsample_library_ProteinQuant_Report.csv` | protein | 48 | 150 231 | 3 477 | 166 896 | 29.10% | 3 477 (the feature itself) |

"Samples" counts distinct `R.FileName` values, i.e. MS runs, not patients — see
the caveats below on runs that were quantified but never deposited. "Unique
proteins" counts the `PG.ProteinAccessions` string **verbatim**, so a
semicolon-separated protein group counts as one identifier. Splitting those
groups into individual accessions gives different numbers, computed separately:
5 274 for the precursor report, 5 277 / 4 619 / 5 297 / 5 815 for the four
protein-level files in the order above. The batch-3 file is the outlier — 3 477
groups expand to 5 815 accessions — so protein-group identifiers are not
comparable across the three PXD022198 reports as strings.

**The precursor file appears three times, once per feature level.** It is
reported at the level its own identifier carries (precursor) and at the two
levels that identifier collapses to:

| Level | Feature identity | Derived from `EG.PrecursorId` by |
| --- | --- | --- |
| precursor | modified sequence + charge | used as-is, e.g. `_HTGSGILSM[Oxidation (M)]ANAGPNTNGSQFFIC[Carbamidomethyl (C)]TAK_.3` |
| peptidoform | modified sequence, charge-agnostic | dropping the `.<charge>` suffix |
| peptide (stripped) | bare amino-acid sequence | dropping the charge suffix, the `[...]` modification blocks and the flanking underscores |

Collapsing merges rows, so "Feature rows" is the number of **non-empty cells
after the collapse**, not the source row count: all three levels are computed
from the same 2 188 036 source rows, of which 248 415 land on a
(run, peptidoform) cell already occupied and 283 073 on an already-occupied
(run, stripped sequence) cell. Completeness therefore uses distinct
(run, feature) pairs, not row counts — the bundled counter says so explicitly in
a `NOTE` line for both collapsed levels. Completeness *rises* as the level
coarsens (73.57% → 75.44% → 76.67%) because merging charge states and
modification states fills cells that were empty for one precursor but observed
for a sibling of the same peptide.

A cell counts as empty when the row is absent, when its value is a missing
token (`NaN`, `NA`, `null`, `Filtered`, empty), or when its value is zero. In
this file only the first of those ever occurs: it holds no missing token and no
zero anywhere, so the three definitions coincide here and the completeness
figures are insensitive to which is used.

"Unique proteins" is 5 196 at all three levels, as it must be — the same file
and the same `PG.ProteinAccessions` column, only the feature axis changes.

Feature rows differs from unique features x samples in every file, and the gap
is a finding rather than rounding:

- The **precursor report holds exactly one row per observed cell** — 2 188 036
  rows for 2 188 036 observed cells — so its 786 164 missing cells have no row
  at all and it carries no null token.
- The **protein report is rectangular but doubled**: its 396 500 rows collapse
  to 259 950 distinct (run, protein group) cells. Every duplicated cell is one
  informative row plus one row that is `NaN` in both `PG.Qvalue` and
  `PG.Quantity`, and **no cell ever carries two different numeric quantities**,
  so de-duplicating by keeping the non-`NaN` row is unambiguous. Counting rows
  instead of cells would overstate this matrix by 53%.
- The **three PXD022198 reports are neither rectangular nor doubled**: beyond
  their explicit `NaN` cells they omit rows entirely — 13 057, 15 456 and
  16 665 cells respectively have no row. Reading them as rectangular tables
  silently drops those.

Missing-value convention: `NaN` is the explicit missing token in the protein
report and in all three PXD022198 reports; the precursor report contains no null
token and represents a missing cell by the absence of its row. Empty fields do
not occur in any of the five. **Zero does not occur either** — a direct count
found exactly 0 values equal to zero in every quantity column across all five
files, so the usual "does zero mean not-quantified" ambiguity cannot affect any
completeness figure here, and `--zero-is-missing` and `--zero-is-value` give
identical results. That is a property of these files, established by counting
them; it is not documented in either PRIDE record, and the records still state
no missing-value convention.

Computed with:

```bash
# zero does not occur in any of these files, so the --zero-is-missing choice
# below is stated for the record and provably changes nothing.
python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level precursor --feature-col 'EG.PrecursorId' --protein-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'EG.TotalQuantity (Settings)' \
  --zero-is-missing \
  PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv

# Peptidoform and stripped-peptide levels: the file carries no such column, so
# derive both from EG.PrecursorId first, then count the derived columns. Running
# the precursor level against this derived file reproduces the row above
# exactly, which is what shows the derivation changed nothing else.
awk -F'\t' -v OFS='\t' '
  NR==1 { print "R.FileName","EG.PrecursorId","Peptidoform","StrippedPeptide","PG.ProteinAccessions","Quantity"; next }
  {
    q=$13; gsub(/\r/,"",q)                      # the file is CRLF
    pf=$11; sub(/\.[0-9]+$/,"",pf)              # peptidoform: drop the charge
    sp=pf;  gsub(/\[[^]]*\]/,"",sp); gsub(/_/,"",sp)   # stripped: drop mods and underscores
    print $2,$11,pf,sp,$4,q
  }' PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv \
  > precursor_levels.tsv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level peptidoform --feature-col 'Peptidoform' --protein-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'Quantity' --zero-is-missing \
  precursor_levels.tsv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level peptide --feature-col 'StrippedPeptide' --protein-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'Quantity' --zero-is-missing \
  precursor_levels.tsv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level protein --feature-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'PG.Quantity' --zero-is-missing \
  PXD022216/20200727_104510_200725_cll_diaPASEF_direct_Report_Protein_long.tsv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level protein --feature-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'PG.Quantity' --zero-is-missing \
  PXD022198/20201207_p3254_o20368_hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level protein --feature-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'PG.Quantity' --zero-is-missing \
  PXD022198/20210117_p3254_o23722_CD19selected_Library_ProteinQuant_Report.csv

python3 .skills/dataset-documentation/scripts/matrix_stats.py \
  --level protein --feature-col 'PG.ProteinAccessions' \
  --layout long --run-col 'R.FileName' --value-col 'PG.Quantity' --zero-is-missing \
  PXD022198/20201112_p3254_o23219_CLLsample_library_ProteinQuant_Report.csv

# zero-occurrence check, per file (column index differs by file):
awk -F'\t' 'NR>1 { v=$13; gsub(/\r/,"",v); if (v+0==0 && v!="NaN" && v!="") z++ } END{print z+0}' \
  PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv
```

**Non-matrix files.** The two annotation files are sample tables, so they get row
and column counts and nothing more. `PXD022216/Annotation_file_timsTOF.txt`:
50 data rows x 14 columns, tab-separated. `PXD022198/Annotation_file.csv`: not
rectangular — three stacked tables, semicolon-separated, 143 non-empty data
lines in total, comprising 91 rows x 28 columns ("Exploratory cohort"), 26 rows
x 28 columns ("Additional cohort") and 18 rows with only the first column
populated ("Library files").

The **exported spectral library** `PXD022216/200723_CLL_library_direct.tsv` is a
fragment-ion assay list with no sample axis, so it gets counts without
completeness: 786 266 fragment rows over 59 617 precursors, 51 525 modified
peptide sequences, 49 707 stripped sequences, 5 198 protein groups, 5 276
UniProt accessions and 5 266 gene symbols, drawn from all 50 diaPASEF runs as
reference runs at a mean 13.19 fragments per precursor, 742 802 of the rows
flagged proteotypic. Every one of those rows carries `Database = sp` and
`FASTAName = uniprot_sprot_2020-01-01_HUMAN`, which confirms from the data the
search-database version the PRIDE record states. The 133 precursors present in
the library but absent from the precursor report were never quantified in any
run.

**These library counts were computed from a copy that is no longer held.** The
file had been fetched while spectral libraries were still assigned to `default`
depth; once the depth rules moved them to the bulk tier it became an unpinned
stray, and it was deleted rather than left as bytes the manifest had never
recorded. The counts above were computed from those bytes before deletion, with
`sha1sum` confirming they matched the publisher hash, so they are measurements
rather than estimates — but they cannot be re-run until `./DOWNLOAD.sh raw`
brings the file back (296 MB, about three minutes on its own).

**Raw instrument files** — the 185 `.raw` and `.d.zip` acquisitions and the
24.2 GiB `.sne` session archive — are at `raw` depth and **were not
downloaded**, so they get no statistics at all. Their counts and upstream sizes
are in the depth table above. The absence of numbers for them is a scoping
decision, not an omission.

**Against what the source claims.** Three comparisons, one agreement and two
gaps:

- *Samples.* The article and both PRIDE records state 117 CLL patient samples.
  `PXD022198/Annotation_file.csv` lists exactly 117 sample runs against 117
  distinct Patient IDs and 117 distinct Sample IDs, and its third table names 18
  further runs as library files: 117 + 18 = 135, exactly the number of `.raw`
  files deposited, with nothing unaccounted for. **Agreement.**
- *Proteins after filtering.* The article states that filtering to proteins with
  fewer than 50% missing values across the 49 retained timsTOF samples left
  **4 977** proteins. Applying that filter to
  `PXD022216/…_Report_Protein_long.tsv` gives **4 944** when the run with the
  fewest quantified protein groups is dropped, and every one of the 50 possible
  single-run exclusions lands between **4 932 and 4 946**. 4 977 is not
  reachable from this table by this filter. The published figure therefore comes
  from a different starting matrix or a different filter definition — plausibly
  DEP's own import and roll-up in R — but the records do not say enough to
  settle it, so the gap is reported unexplained.
- *Runs quantified versus runs deposited.* The three PXD022198 reports quantify
  151 distinct runs between them (50 + 53 + 48, with no run appearing in two
  reports), but only 117 of those 151 exist as `.raw` files in the deposit. The
  annotation file's closing line accounts for the direction of the gap — "Only
  files that met the quality criteria for inclusion in the analysis were
  uploaded" — but does not name the 34 runs, so they cannot be traced to raw
  data here.

## Before you analyse these data

| Aspect | Value |
| --- | --- |
| Units | Raw acquisitions: vendor-native, no interpretable units. Spectronaut reports: `PG.Quantity` and `EG.TotalQuantity` are Spectronaut intensity values on a linear, dimensionless scale; `PG.Qvalue` and `EG.Qvalue` are q-values in [0,1]; `PG.Coverage` is a percentage string with a literal `%` |
| Encoding | `derived:` observed on the seven downloaded files. All are ASCII with **CRLF** line terminators. The two PXD022216 reports and the spectral library are tab-separated; the three PXD022198 quantification reports are comma-separated; `PXD022198/Annotation_file.csv` is **semicolon**-separated despite its `.csv` name and is sectioned rather than rectangular. Read every file with an explicit delimiter and CRLF-tolerant line handling. Not observed for the 187 `raw`-depth files, which are not downloaded |
| Missing-value convention | `derived:` and **not the same in both deposits**. `NaN` in the PXD022216 protein report and in all three PXD022198 reports; no null token at all in the PXD022216 precursor report, where a missing cell is an absent row. No empty field occurs in any of them, and no value equals zero, so the zero ambiguity cannot bite. Neither PRIDE record states any of this |
| Normalization state | Partly resolved. One file names it: `…hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv` is a Spectronaut *normal*ised report. For the other four, UNVERIFIED: neither PRIDE record says whether Spectronaut's internal normalisation was enabled, and the exports carry no column recording it. Both records do state that background correction, scaling and the variance-stabilizing transformation were applied afterwards in R, so every deposited report is pre-vsn and pre-batch-correction. Treat them as unlogged, untransformed intensities |
| Quantitative columns | `PG.Quantity` (protein group) and `EG.TotalQuantity (Settings)` (precursor); `PG.Qvalue` / `EG.Qvalue` are q-values in [0,1]; `PG.Coverage` is a percentage *string* carrying a literal `%`, so it needs stripping before numeric use |

Caveats worth knowing before you commit compute:

- **One file is defective upstream.** `20210107_003_S281243_CLL_CD19selected_Pool6.raw`
  in PXD022198 is served by the archive at 4096 bytes, while its PRIDE record
  states 661 866 438 bytes. This was confirmed from three independent upstream
  sources on 2026-08-20 (the file-metadata API, an HTTPS HEAD, and the archive's
  own directory listing). Its Tier A checksum check will fail, and
  `DOWNLOAD.sh` will correctly refuse to install it. Nothing in this directory
  can repair that; it needs a report to the PRIDE helpdesk.
- **18 of the 135 PXD022198 raw files are library runs, not samples.** The
  annotation file's third table, headed "Library files", names them exactly:
  `20191016_02_L1_rep` and `_03_L2` through `_08_L6`, the six
  `…CD19selected_Pool1–6` runs, and the six `…screen2_Pool1–6` runs. The
  remaining 117 are the 117 patient samples. Exclude the library runs from any
  per-sample analysis.
- **34 quantified runs were never deposited as raw files**, and the 18 library
  runs appear in no quantification report. Details in the statistics section.
- **PXD022216 has 50 raw acquisitions for 49 analysed samples.** Its
  data-processing protocol states one outlier was excluded downstream for a
  singularly large proportion of missing values. Both reports still cover all 50
  runs, so the exclusion happened after export.
- **The two deposits overlap almost completely in patients.** All 50 PXD022216
  (timsTOF) patients also appear in PXD022198 (Lumos): 49 are the full Lumos
  batch-1 set and the 50th is patient P0641 from Lumos batch 2. P0641 is also
  the only patient whose Sample ID differs between deposits (13PB0403 on
  timsTOF, 14PB0068 on Lumos) — a different aliquot. So PXD022216 is essentially
  Lumos batch 1 re-measured on the timsTOF, and pooling the deposits
  double-counts 50 patients unless you deduplicate on Patient ID.
- **Blank is not zero in `Annotation_file_timsTOF.txt`.** Its genetic columns are
  sparse: `trisomy12` and `IGHV.status` are complete for all 50 rows, but
  `DDX3X` is blank in 45, `NOTCH1` in 42, `SF3B1` in 43 (with one explicit `0`)
  and `del11q` in 44; `treatStatus` carries 5 literal `NA`. By contrast
  `PXD022198/Annotation_file.csv` has no blank cell in its 117 sample rows and
  writes `NA` explicitly where a call is absent. Reading a blank as wild-type in
  the timsTOF annotation would invent genotypes.
- **`.d.zip` needs unzipping before use**, and a decompressed Bruker `.d` folder
  is substantially larger than its archive. Budget disk accordingly.
- **The published `.sne` is a Spectronaut session archive**, tied to the
  Spectronaut version that wrote it; it is not a portable results table. It sits
  at `raw` depth.

## Integrity

All 194 files are Tier A: the PRIDE file-metadata API publishes a per-file SHA-1
for every one of them, fetched on 2026-08-20 and saved verbatim under
`provenance/upstream/`, and that hash is the gate `DOWNLOAD.sh` applies before a
downloaded file is installed. No file is Tier B or Tier C. 7 of the 194 rows are
pinned — the `default` depth, each verified against its publisher SHA-1 on
2026-08-20 before its `bytes`/`sha256`/`pinned_date` triple was written. The
other 187 are `PENDING`.

`--verify-only` is therefore clean at every depth: 7 `OK` and 0 problems at
`default`, and at `raw` the 187 unfetched rows report `NOT_YET_DOWNLOADED`,
which is a match between manifest and disk rather than a failure. There is no
file on disk that the manifest has not recorded, and no pinned row whose file is
absent.

Data files are set read-only to prevent accidental modification. To edit one
deliberately:

```bash
chmod u+w <path from MANIFEST.tsv>
```

Note that this protects against accidental edits, not deletion — the containing
directory stays writable. Run `./DOWNLOAD.sh --verify-only` to confirm the files
are intact.

This directory is under version control, and `MANIFEST.tsv` is the integrity
baseline. Every change to it is a separate commit with its reason in the message,
so `git log -p MANIFEST.tsv` is the full record of when a checksum moved and
why. The data files themselves are not versioned — the manifest and
`DOWNLOAD.sh` are what reproduce them.

**A single fingerprint for the bytes on disk.** `MERKEL-TREE.json` is a Merkle
tree over the downloaded data — the two deposit directories and nothing else. A
file's node hashes its bytes, a directory's node hashes its children's sorted
hashes, so the root value covers every byte of the current download and two
copies of this dataset can be compared with one string instead of a checksum
list:

```
sha256-7cf6f3ddb1f074c20d1c79e2628aff850669f73a399abe43f31534ca27a7d0e5
```

This is a fingerprint of *what is currently downloaded*, not a constant of the
dataset: it covers the 7 files of the `default` depth, and fetching a deeper
depth will legitimately change it. `MANIFEST.tsv` remains the authority on what
each file's bytes must be — the tree is derived, so regenerate it rather than
edit it:

```bash
# tool: idf-utilities/tools/command-line/merkel-tree/merkel-tree.py
# the exact tool commit that produced the hashes is recorded in the JSON's
# tool_commit field, so the hashing logic can be checked out and re-run
merkel-tree.py . -a sha256sum -o MERKEL-TREE.json \
  -s '.git' -s '.gitignore' -s '.skills' -s 'provenance' \
  -s 'README.md' -s 'PROVENANCE.md' -s 'MANIFEST.tsv' \
  -s 'DOWNLOAD.sh' -s 'TEST_DOWNLOAD.sh' -s 'MERKEL-TREE.json'
```

The `-s` list is what confines the tree to the data: every documentation and
tooling path in this directory is excluded by name. Two things in the JSON are
the check that the confinement held — the `skipped` array records the patterns
applied, and the root node's `children` must be exactly `PXD022198` and
`PXD022216`. Its 7 file hashes were compared against the 7 pinned `sha256`
values in `MANIFEST.tsv` and agree exactly.

## Files in this directory

| File | Purpose |
| --- | --- |
| `PROVENANCE.md` | citation, license, per-file descriptions, integrity record |
| `MANIFEST.tsv` | authoritative paths, sizes, checksums, and source URLs |
| `MERKEL-TREE.json` | Merkle tree of the downloaded bytes; one root hash fingerprints the whole download |
| `DOWNLOAD.sh` | retrieve and verify the data; `--help` for options |
| `TEST_DOWNLOAD.sh` | check that `DOWNLOAD.sh` is correct and safe |
| `.gitignore` | keeps the data files out of version control |
| `provenance/upstream/` | upstream checksum artifacts, saved verbatim as evidence |
