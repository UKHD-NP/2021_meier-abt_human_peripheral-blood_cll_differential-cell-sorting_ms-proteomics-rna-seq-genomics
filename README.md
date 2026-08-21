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
| Organism / sample type | *Homo sapiens*, peripheral blood. Main cohort batch 1 (samples 1–49): thawed mononuclear cells; batch 2 (samples 50–91): CD19+ CLL cells selected from mononuclear cells by MACS; additional cohort batch 3 (samples 92–117): 100 000 FACS-sorted CD19+ CD5+ light-chain-restricted cells per sample |
| Conditions / comparison groups | Not treatment arms — patient samples stratified post hoc by genetic lesion. The paper's primary contrasts are trisomy 12 and IGHV mutational status; further tested: mutated SF3B1, trisomy 19, del(17)(p13), del(11)(q22.3), mutated DDX3X, mutated MED12 |
| Biological replicates | 117 CLL patient samples in the study overall. The PXD022198 record states 117 samples profiled (139 files deposited); the PXD022216 record states 49 samples (55 files deposited, 50 of them raw acquisitions) and notes that one outlier was excluded from downstream analysis for a singularly large proportion of missing values |
| Technical replicates | UNVERIFIED: no technical-replicate design is stated in either PRIDE record or in the article Methods. Some PXD022198 filenames carry a `_rep` suffix and some carry `Pool`, which is suggestive but not documented; the run-to-sample mapping is the annotation file in each deposit |
| Instrument / platform | PXD022216: Bruker timsTOF Pro coupled to a Bruker nanoElute, PicoFrit column (75 µm × 450 mm, Reprosil C18 Aq 1.9 µm), 60 °C, 400 nL/min, 2→24% B over 100 min. PXD022198: Thermo Orbitrap Fusion Lumos with a Digital PicoView source, coupled to a Waters M-Class UPLC; MZ Symmetry C18 trap then nanoEase MZ C18 HSS T3 (75 µm × 250 mm), 300 nL/min, 8→22% B in 112 min, 32% in 8 min, 95% in 5 min; Tune Plus 2.1 |
| Assay / protocol | Lyophilized cell pellets resuspended in 8 M urea / 100 mM ammonium hydrogen carbonate, VialTweeter sonication, BCA or Qubit protein assay, Benzonase, TCEP reduction, iodoacetamide alkylation, trypsin 1:50 overnight at 37 °C, C18 desalting, Biognosys iRT peptides spiked before injection. PXD022216: standard diaPASEF (trapped-ion-mobility DIA), 1 µL / 100 ng on column. PXD022198: DDA and DIA, HCD at 30% (DDA) / 28% (DIA) normalized collision energy, MS1 resolution 120 000 and MS2 30 000, MS1 350–1500 *m/z*, MS2 200–1800 *m/z* for DIA, 4 µL / 200 ng on column |
| Processing pipeline | Spectronaut library building and DIA search, then R. PXD022216: direct (DIA-only) library, searched against the SwissProt-reviewed human UniProt subset version 2020-01-01, 20 367 entries, decoys by "mutation". PXD022198: hybrid (DDA+DIA) library, searched against SwissProt-reviewed human UniProt version 2019-07-09, 20 913 entries, decoys by sequence reversal; trypsin, max. 2 missed cleavages, carbamidomethyl (C) fixed, acetyl (protein N-term) and oxidation (M) variable, b/y ions, 1% FDR at peptide and protein level, quantification restricted to proteins with ≥2 proteotypic peptides. Downstream: background correction, scaling and variance-stabilizing transformation, ≥50% completeness filter |
| Software versions | Spectronaut v14.4 (PXD022216); Spectronaut v13.4 for PXD022198 main-cohort batch 1 and v14.5 for batch 2 and the FACS-sorted batch 3; R 3.6.0 with Bioconductor DEP; downstream analysis used proDA, limma (incl. CAMERA), DESeq2, DEXSeq, sva/ComBat and coxph |

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

Everything is upstream; nothing has been downloaded at the point this baseline
was written. `MANIFEST.tsv` therefore has all 194 rows in the planned state,
with `bytes`, `sha256` and `pinned_date` all `PENDING`.

Files are grouped into three download depths. `./DOWNLOAD.sh` with no argument
fetches `default`; pass `supplementary` or `raw` to go deeper. Depth is
cumulative, so `raw` fetches everything.

| Depth | Contents | Files | Total size | Downloaded here |
| --- | --- | --- | --- | --- |
| `default` | the analysis-ready tables: the Spectronaut precursor and protein reports, the three per-batch protein-quantification reports, and both annotation files | 7 | 552.2 MiB | not yet |
| `supplementary` | adds supplementary and secondary files. Neither deposit contains any, so this resolves to the same 7 files as `default` | 7 | 552.2 MiB | not yet |
| `raw` | adds the bulk inputs: 185 raw MS acquisitions, the exported Spectronaut spectral library, and the 24.2 GiB `.sne` session archive | 194 | 583.9 GiB | not yet |

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

Not yet computed. Nothing has been downloaded at this baseline, and a statistic
about a file we do not hold would be an estimate rather than a measurement.
Five of the deposited files are sample × feature quantitative matrices and one
is a spectral library; once `default` depth is retrieved, this section carries
their sample counts, feature counts, cells and completeness, each beside the
`scripts/matrix_stats.py` invocation that produced it.

Missing-value convention: UNVERIFIED — sought in both PRIDE
`dataProcessingProtocol` fields and in the article Methods; neither states which
token the Spectronaut exports use for an unquantified cell, nor whether zero
means "not quantified". It will be established from the files themselves at the
annotation step, and completeness reported both ways if it stays ambiguous.

Computed with:

```bash
# no invocations yet — nothing is downloaded
```

## Before you analyse these data

| Aspect | Value |
| --- | --- |
| Units | Raw acquisitions: vendor-native, no interpretable units. Spectronaut reports: `PG.Quantity` and `EG.TotalQuantity` are Spectronaut intensity values on a linear, dimensionless scale; `PG.Qvalue` and `EG.Qvalue` are q-values in [0,1]; `PG.Coverage` is a percentage string with a literal `%` |
| Encoding | UNVERIFIED: no file has been downloaded, so no encoding, delimiter or line terminator has been observed. The PRIDE records state only file names and types |
| Missing-value convention | UNVERIFIED: not stated in either PRIDE record or the article Methods |
| Normalization state | Partly stated upstream: one file names it — `…hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv` is a Spectronaut *normal*ised report. For the rest, UNVERIFIED: neither record says whether Spectronaut's internal normalisation was enabled. Both records do state that background correction, scaling and the variance-stabilizing transformation were applied afterwards in R, so every deposited report is pre-vsn and pre-batch-correction |

Caveats worth knowing before you commit compute:

- **One file is defective upstream.** `20210107_003_S281243_CLL_CD19selected_Pool6.raw`
  in PXD022198 is served by the archive at 4096 bytes, while its PRIDE record
  states 661 866 438 bytes. This was confirmed from three independent upstream
  sources on 2026-08-20 (the file-metadata API, an HTTPS HEAD, and the archive's
  own directory listing). Its Tier A checksum check will fail, and
  `DOWNLOAD.sh` will correctly refuse to install it. Nothing in this directory
  can repair that; it needs a report to the PRIDE helpdesk.
- **File counts exceed sample counts.** 50 raw acquisitions for 49 stated
  samples in PXD022216; 135 raw acquisitions for 117 stated samples in
  PXD022198, including runs whose names contain `Pool`, `L1`–`L6` and `_rep`.
  Do not infer the run-to-sample assignment from filenames — the annotation file
  in each deposit is the documented mapping, and both are at `default` depth.
- **The two deposits overlap in biology, not in files.** Analysing them together
  risks double-counting patients unless sample identity is reconciled through
  both annotation files.
- **`.d.zip` needs unzipping before use**, and a decompressed Bruker `.d` folder
  is substantially larger than its archive. Budget disk accordingly.
- **The published `.sne` is a Spectronaut session archive**, tied to the
  Spectronaut version that wrote it; it is not a portable results table. It sits
  at `raw` depth.

## Integrity

All 194 files are Tier A: the PRIDE file-metadata API publishes a per-file SHA-1
for every one of them, fetched on 2026-08-20 and saved verbatim under
`provenance/upstream/`, and that hash is the gate `DOWNLOAD.sh` applies before a
downloaded file is installed. No file is Tier B or Tier C. Every row's local
observation — `bytes`, `sha256`, `pinned_date` — is `PENDING` at this baseline
and is written by `DOWNLOAD.sh` only after the file passes that gate.

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

## Files in this directory

| File | Purpose |
| --- | --- |
| `PROVENANCE.md` | citation, license, per-file descriptions, integrity record |
| `MANIFEST.tsv` | authoritative paths, sizes, checksums, and source URLs |
| `DOWNLOAD.sh` | retrieve and verify the data; `--help` for options |
| `TEST_DOWNLOAD.sh` | check that `DOWNLOAD.sh` is correct and safe |
| `.gitignore` | keeps the data files out of version control |
| `provenance/upstream/` | upstream checksum artifacts, saved verbatim as evidence |
