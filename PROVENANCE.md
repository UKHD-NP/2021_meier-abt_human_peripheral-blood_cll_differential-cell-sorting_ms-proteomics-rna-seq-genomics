# Provenance — CLL DIA-MS proteomics — PRIDE PXD022216 + PXD022198 (Meier-Abt et al., Blood 2021)

## Citation

Meier-Abt F, Lu J, Cannizzaro E, Pohly MF, Kummer S, Pfammatter S, Kunz L,
Collins BC, Nadeu F, Lee KS, Xue P, Gwerder M, Roiss M, Hüllein J, Scheinost S,
Dietrich S, Campo E, Huber W, Aebersold R, Zenz T. The protein landscape of
chronic lymphocytic leukemia. *Blood*. 2021;138(24):2514–2525.
doi:10.1182/blood.2020009741. PMID 34189564.

| Field | Value |
| --- | --- |
| Persistent identifier | ProteomeXchange **PXD022216** (timsTOF Pro) and **PXD022198** (Orbitrap Fusion Lumos); publication DOI 10.1182/blood.2020009741. Neither PRIDE record carries a dataset DOI of its own (the `doi` field is empty in both project records) |
| Version | ProteomeXchange accession version 2 for PXD022216 and version 3 for PXD022198. Latest revision of both is dated 2024-10-22, changelog entry "Updated project metadata". PXD022198 also has an earlier revision dated 2021-09-27, "Updated publication reference for PubMed record(s): 34189564" |
| Release date | Public since 2021-09-27 (PXD022216) and 2021-09-24 (PXD022198); submitted 2020-10-28 and 2021-04-08 respectively |
| Last modified upstream | Deposit metadata: 2024-10-22 (both). Data files: the PRIDE records give per-file `updatedDate` 2020-10-28 (PXD022216) and 2021-04-08 (PXD022198); the archive's own HTTPS `Last-Modified` headers are 2022-04-14/15 for every file, which reflects a storage migration rather than a content change |
| Publisher / host | PRIDE Archive, EMBL-EBI, Hinxton, UK; a ProteomeXchange partner repository |
| Creators | PXD022216 — submitter and lab PI: Ben Collins, Queen's University Belfast, UK. PXD022198 — submitter: Fabienne Meier-Abt, Institute of Medical Genetics, University of Zurich; lab PI: Thorsten Zenz, Medical Oncology and Hematology, University Hospital and University of Zurich. Full author list in the citation above |
| Contact point | `ben.collins@qub.ac.uk` (PXD022216, per the PRIDE record); `fabienne.meier-abt@usz.ch` (PXD022198, per the PRIDE record). Corresponding authors of the article: Thorsten Zenz `thorsten.zenz@usz.ch`, Ruedi Aebersold `aebersold@imsb.biol.ethz.ch`, Wolfgang Huber `wolfgang.huber@embl.org` |

## License and reuse

| Field | Value |
| --- | --- |
| License | Creative Commons Public Domain (CC0), as stated in the `license` field of both PRIDE project records |
| Reuse terms | CC0 places no conditions on reuse of the deposited data |
| Redistribution | Permitted under CC0. Note that the *article* is not open access (Europe PMC reports `isOpenAccess: N`, `license: null`); this license covers the deposits, not the paper or its supplementary tables |
| Access conditions | Open, no registration, no embargo, no application. Retrieval is unauthenticated HTTPS from `ftp.pride.ebi.ac.uk`. No rate limit is published; parallel requests at concurrency 8 were refused during this session and succeeded at concurrency 3, so keep concurrency low |

Required attribution:

> Meier-Abt F, Lu J, Cannizzaro E, Pohly MF, Kummer S, Pfammatter S, Kunz L,
> Collins BC, Nadeu F, Lee KS, Xue P, Gwerder M, Roiss M, Hüllein J,
> Scheinost S, Dietrich S, Campo E, Huber W, Aebersold R, Zenz T. The protein
> landscape of chronic lymphocytic leukemia. Blood. 2021;138(24):2514–2525.
> Data: ProteomeXchange PXD022216 and PXD022198 via PRIDE.

CC0 imposes no attribution requirement; the string above is the scholarly
convention for citing these deposits, not a license condition. The consent and
ethics basis for the underlying patient samples is stated in the article
(informed consent; ethics approvals S-206/2011 and S-356/2013, plus Institutional
Ethics Committee approval for the Barcelona samples). CC0 on the deposit does not
by itself settle what secondary use of human-subject data is permissible in your
jurisdiction or under your institution's rules.

## Sources considered and download depth

Every file source weighed for inclusion, whether it was included, and at which
depth. A source considered and rejected is recorded here rather than omitted —
the next reader needs to know it was looked at.

| File source | Included | Depth | Rationale |
| --- | --- | --- | --- |
| PRIDE PXD022216 — Spectronaut precursor and protein long reports, timsTOF annotation file | yes | `default` | The analysis-ready quantitative matrices and the run-to-sample key for the timsTOF platform |
| PRIDE PXD022198 — three per-batch Spectronaut protein-quantification reports, annotation file | yes | `default` | The analysis-ready quantitative matrices and the run-to-sample key for the Lumos platform |
| PRIDE PXD022216 — 50 `.d.zip` Bruker timsTOF acquisitions | yes | `raw` | Raw instrument files: `raw` by the skill's file-type rule. 218.1 GiB |
| PRIDE PXD022198 — 135 `.raw` Thermo Lumos acquisitions | yes | `raw` | Raw instrument files: `raw` by the skill's file-type rule. 340.8 GiB |
| PRIDE PXD022216 — exported Spectronaut spectral library `200723_CLL_library_direct.tsv` | yes | `raw` | A spectral library, which the skill's file-type rule places at `raw` depth. It is a fragment-ion assay list, not a sample × feature matrix |
| PRIDE PXD022216 — Spectronaut `.sne` session archive | yes | `raw` | A 24.2 GiB analysis workspace that needs Spectronaut itself to open and is coupled to the version that wrote it. Bulk input, not an analysis-ready table |
| Supplementary tables and figures of the *Blood* article | held locally, not in the manifest | n/a | Supplement 1 carries the per-patient clinical and genetic metadata (Table S1) needed to analyse the deposits. The publisher blocks automated retrieval, so it was obtained by hand and is recorded by checksum under "Manually obtained files", not by `DOWNLOAD.sh` |
| DNA-seq, RNA-seq and ex vivo drug-response layers | no | n/a | Not part of either deposit. The article states they were generated previously and are distributed in the Bioconductor package `BloodCancerMultiOmics2017` |
| Published analysis code and Rmarkdown workflows | no | n/a | Code, not data. URLs transcribed from the article's data-sharing statement and left UNVERIFIED |
| PRIDE Aspera transfer endpoints | no | n/a | An alternative transport for the same bytes, not a separate source. `DOWNLOAD.sh` uses HTTPS only, so the manifest records only HTTPS URLs |

Depths actually downloaded so far: `default` (and therefore `supplementary`,
which resolves to the same 7 files), on 2026-08-20. At `raw`, the 117
patient-sample runs of PXD022198 were fetched with `./DOWNLOAD_PATIENT_RUNS.sh`
on 2026-10-13/14, on a different machine from the one this documentation was
written on, and their pins were committed from there. The other 70 `raw` rows
are `PENDING` and `./DOWNLOAD.sh raw` will fetch them, 252.9 GiB at the
archive's observed ~1.8 MB/s.

One of those 70, the exported spectral library, was briefly on disk under an
earlier depth assignment and was deleted rather than left unpinned; see the
integrity record.

## File descriptions

Descriptions only — paths, sizes, and checksums live in `MANIFEST.tsv`. A file
whose name already says what it is gets no row here.

| Path | Description | Description source |
| --- | --- | --- |
| `PXD022216/fmeierab_T190525_CLL_diaPASEF_*.d.zip` | Zipped Bruker `.d` acquisition folders, timsTOF Pro, standard diaPASEF. 50 runs, numbered 01–50 contiguously with a trailing four-digit run id. Primary measurements of this deposit | PRIDE file category "Associated raw file URI"; acquisition mode from the PXD022216 sample-processing protocol and the article Methods |
| `PXD022216/200723_CLL_library_direct.tsv` | Spectronaut spectral library exported for the direct (DIA-only) library used to search this deposit: a fragment-ion assay list, 35 columns, tab-separated, one row per fragment, no sample axis. Every row names `Database = sp` and `FASTAName = uniprot_sprot_2020-01-01_HUMAN`, independently confirming the search-database version the PRIDE record states. Counts in README.md. At `raw` depth and not currently held: a copy fetched under an earlier depth assignment was deleted rather than left unpinned | PRIDE file category "Other type file URI"; library construction from the PXD022216 data-processing protocol; `derived:` column values and counts read from that copy before it was deleted |
| `PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv` | Spectronaut precursor-level report, long format. 13 columns, tab-separated, CRLF, 2 188 036 data rows: run name and replicate index, protein-group accessions/descriptions/names/coverage, protein-group q-value and quantity, precursor id, precursor q-value and total quantity. Holds exactly one row per observed cell and no null token, so unquantified precursors are absent rather than `NaN`. Its 50 distinct run names match the 50 `.d.zip` stems exactly. README.md reports it at three feature levels — precursor as deposited, plus the peptidoform and stripped-peptide levels its `EG.PrecursorId` collapses to | PRIDE file category "Search engine output file URI"; `derived:` header row and full-file counts read from the downloaded file |
| `PXD022216/20200727_104510_200725_cll_diaPASEF_direct_Report_Protein_long.tsv` | Spectronaut protein-level report, long format, companion to the precursor report above. 10 columns, tab-separated, CRLF. Rectangular over 50 runs x 5 199 protein groups with `NaN` for unquantified cells, but it carries a second, all-`NaN` row for most cells; the duplicate never conflicts with the informative one | PRIDE file category "Search engine output file URI"; `derived:` matrix shape and duplicate structure counted from the downloaded file |
| `PXD022216/20200727_105729_200725_cll_diaPASEF_direct.sne` | Spectronaut session archive for the direct-library search of this deposit: the analysis workspace, coupled to the Spectronaut release that wrote it (v14.4), not a portable results table. Its export timestamp places it in the same batch as the two long-format reports — `20200727_103309`, `20200727_104510`, `20200727_105729`, all carrying the `200725_cll_diaPASEF_direct` analysis name | PRIDE file category "Other type file URI"; export batch inferred from the filename timestamps; that `.sne` is Spectronaut's session format is general knowledge about the format, not a statement either PRIDE record makes |
| `PXD022216/Annotation_file_timsTOF.txt` | Experimental-design annotation for the timsTOF deposit. Tab-separated, CRLF, 14 columns, 50 data rows whose `File name` values match the 50 `.d.zip` stems exactly: File name, Patient ID, Pseudonym, Sample ID, Diagnosis from tumorbank, Gender, IGHV.status, trisomy12, DDX3X, NOTCH1, SF3B1, del11q, Leukocyte count, treatStatus. 50 distinct Patient IDs, Sample IDs and pseudonyms — no technical replicates. Unlike the PXD022198 annotation its genetic columns are sparse: blank cells, not `NA`, in 42–45 of 50 rows for DDX3X, NOTCH1, SF3B1 and del11q. All 50 patients also appear in PXD022198 | PRIDE file category "Experimental design file URI"; `derived:` all column and row facts read from the downloaded file |
| `PXD022198/20191016_0??_S*_CLL_*.raw` | Lumos raw acquisitions of the 49 **batch 1** patient samples — main cohort, thawed mononuclear cells. All 49 appear in the "Exploratory cohort" table of the annotation file with `Batch = batch1`, each against a distinct Patient ID and Sample ID; 5 carry a `_rep` suffix in the run name, which the annotation shows is not a replicate of another deposited run | PRIDE file category "Associated raw file URI"; `derived:` first section of the downloaded annotation file; cell preparation from the article Methods |
| `PXD022198/20191016_0?_L?*.raw` | Spectral-library runs, not patient samples: `20191016_02_L1_rep` and `_03_L2` through `_08_L6`. Named verbatim in the "Library files" table of `PXD022198/Annotation_file.csv`, and absent from all three quantification reports | PRIDE file category "Associated raw file URI"; `derived:` third section of the downloaded annotation file |
| `PXD022198/20201112_*_CLL_screen2_[0-9]*_Diseased.raw` | Lumos raw acquisitions of the 26 **batch 3** patient samples — the article's "additional cohort", FACS-sorted CD19+ CD5+ cells. All 26 appear in the "Additional cohort" table of the annotation file, each against a distinct Patient ID and Sample ID | PRIDE file category "Associated raw file URI"; `derived:` second section of the downloaded annotation file; cell preparation from the article Methods |
| `PXD022198/20201112_*_CLL_screen2_Pool*_Diseased.raw` | Spectral-library runs for batch 3, `Pool1`–`Pool6`, not patient samples. Named verbatim in the "Library files" table of the annotation file and absent from every quantification report | PRIDE file category "Associated raw file URI"; `derived:` third section of the downloaded annotation file |
| `PXD022198/20210107_*_CLL_CD19selected_[0-9]*_Diseased.raw` | Lumos raw acquisitions of the 42 **batch 2** patient samples — main cohort, CD19+ cells selected by MACS. All 42 appear in the "Exploratory cohort" table of the annotation file with `Batch = batch2`, each against a distinct Patient ID and Sample ID | PRIDE file category "Associated raw file URI"; `derived:` first section of the downloaded annotation file; CD19 selection from the PXD022198 sample-processing protocol and the article Methods |
| `PXD022198/20210107_*_CLL_CD19selected_Pool*.raw` | Spectral-library runs for batch 2, `Pool1`–`Pool6`, not patient samples; named verbatim in the "Library files" table of the annotation file. **`20210107_003_S281243_CLL_CD19selected_Pool6.raw` is defective upstream** — see the integrity record below | PRIDE file category "Associated raw file URI"; `derived:` third section of the downloaded annotation file |
| `PXD022198/20201112_p3254_o23219_CLLsample_library_ProteinQuant_Report.csv` | Spectronaut protein-quantification report covering **batch 3** only: 48 `…screen2…` runs, of which 26 are deposited as raw files. Comma-separated, CRLF, five columns, `NaN` for unquantified cells, and non-rectangular. Its protein grouping differs from the other two reports: 3 477 groups expand to 5 815 accessions. Shape and completeness in README.md | PRIDE file category "Search engine output file URI"; `derived:` run membership and matrix shape counted from the downloaded file |
| `PXD022198/20201207_p3254_o20368_hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv` | Spectronaut protein-quantification report for the hybrid (DDA+DIA) library, restricted to proteins with at least two proteotypic peptides — the quantification rule stated in the deposit's data-processing protocol. The `normalReport` element of the name marks it as Spectronaut's normalised export, the only one of the five quantitative files whose normalisation state is recorded anywhere. Covers **batch 1** only: 50 `20191016_*` runs, of which 49 are deposited as raw files | PRIDE file category "Search engine output file URI"; the ≥2-proteotypic-peptide rule from the PXD022198 data-processing protocol; `derived:` run membership and matrix shape counted from the downloaded file |
| `PXD022198/20210117_p3254_o23722_CD19selected_Library_ProteinQuant_Report.csv` | Spectronaut protein-quantification report for the CD19-selected library, covering **batch 2** only: 53 `…CD19selected…` runs, of which 42 are deposited as raw files. Shape and completeness in README.md | PRIDE file category "Search engine output file URI"; `derived:` run membership and matrix shape counted from the downloaded file |
| `PXD022198/Annotation_file.csv` | Experimental-design annotation, and the key to the whole deposit. **Semicolon**-separated despite the `.csv` name, CRLF, and sectioned rather than rectangular: three stacked tables — "Exploratory cohort" (91 sample runs, batch1 = 49 and batch2 = 42), "Additional cohort" (26 sample runs, batch3), and "Library files" (18 runs, no metadata columns) — followed by the line "Only files that met the quality criteria for inclusion in the analysis were uploaded." The two cohort tables carry, per run: Patient ID, Sample ID, Diagnosis, pseudonymised ID, batch, sex, age, leukocyte count, overall survival (years), died or not, time to treatment (years), treated after sampling, IGHV status, and 0/1/`NA` calls for trisomy12, trisomy19, del13q, del11q, del17p, SF3B1, TP53, NOTCH1, ATM, BRAF, EGR2, MED12, DDX3X and U1. Its 135 run names account for exactly the 135 deposited `.raw` files, with none left over | PRIDE file category "Other type file URI"; `derived:` structure and every count read from the downloaded file |

The description source is either a named upstream document, or
`derived: <what was inspected>` for a description read off the file itself after
download — a header row, an archive listing, a column dictionary inside the file.
Keep the two distinct: what the publisher says a file is and what the bytes show
it to be are different claims, and they occasionally disagree. Rows marked
`derived:` were completed after the `default`-depth download; the `raw`-depth
rows other than the spectral library remain upstream-sourced only, because those
files have not been retrieved.

## Integrity record

| Tier | Count | Meaning |
| --- | --- | --- |
| A | 194 | verified against a publisher-supplied checksum |
| B | 0 | verified against an upstream size only |
| C | 0 | local pin only — drift detection, no external verification |

Upstream checksum authority for Tier A files: the PRIDE Archive file-metadata
API, endpoint `https://www.ebi.ac.uk/pride/ws/archive/v3/projects/{accession}/files`,
which returns a per-file `checksum` field, fetched 2026-08-20. Artifacts saved
verbatim under `provenance/upstream/`:
`pride_api_v3_files_PXD022216_page0.json` (55 records),
`pride_api_v3_files_PXD022198_page0.json` (100 records) and
`pride_api_v3_files_PXD022198_page1.json` (39 records).
`provenance/upstream/FETCH_LOG.tsv` records every URL fetched, its HTTP status,
and the tool used.

**The algorithm.** The API does not label the algorithm of its `checksum`
field. It is recorded here as SHA-1 on two grounds, both checked rather than
assumed: every one of the 194 values is exactly 40 lowercase hex digits, and one
file that was already on disk before this bundle was written hashes to its
published value under SHA-1 — `sha1sum` of the PXD022216 precursor report equals
the `checksum` the API publishes for it, byte for byte. That is a direct
confirmation on real data, not an inference from length alone.

**What was not found.** No sidecar checksum file (`*.md5`, `*.sha256`,
`CHECKSUMS`, `MD5SUMS`) exists in either deposit directory — checked against the
archive's own HTTPS directory listings, saved as
`provenance/upstream/ftp_https_dirlist_PXD022216.html` and
`ftp_https_dirlist_PXD022198.html`. The archive returns no `Digest` or
`Content-MD5` response header; its `ETag` values are Apache inode/size/mtime
tokens, not content hashes, and are not used here. The article's Methods quote
no hashes. The PRIDE API SHA-1 is therefore the strongest authority available,
and it is fetched over the same channel as the data — so it protects against
transmission error, truncation and a stale mirror, but not against a compromised
source.

**Corroborating evidence, independent of the hashes.** All 194 retrieval URLs
were confirmed to answer HTTP 200 over HTTPS on 2026-08-20, and each response's
`Content-Length` was compared against the byte count in the API record; the
full HEAD transcript is saved as `provenance/upstream/http_head_2026-08-20.tsv`.
193 of 194 agreed exactly.

**The one disagreement — reported, not resolved.**
`20210107_003_S281243_CLL_CD19selected_Pool6.raw` in PXD022198 is stated as
661 866 438 bytes by the PRIDE file record but served at 4096 bytes by the
archive. Three independent upstream sources agree the served object is 4096
bytes: the HTTPS `Content-Length`, a repeat HEAD with a stable `ETag`, and the
archive's own directory listing, which shows `4.0K`. The file appears truncated
in the archive's storage. Its Tier A check is expected to fail and
`DOWNLOAD.sh` will refuse to install it; that failure is the correct outcome and
must not be worked around by editing the manifest. Resolving it requires the
PRIDE helpdesk.

**The local pins.** The `sha256` column is a local drift pin and is a different
claim from the upstream SHA-1: it proves only that a file has not changed since
it was hashed here, and proves nothing about whether the correct file was
received. 7 of 194 rows are pinned — the `default` depth, on 2026-08-20. The
three fields move as a unit, written together by `DOWNLOAD.sh` after a file
passes its tier gate. That is the only manifest mutation the script performs
outside `--refresh-manifest`, it touches only those three columns, and it never
turns a populated pin into a different one without `--force`. All seven files
were already on disk when the pins were taken, so each was verified against its
publisher SHA-1 and pinned without any transfer; none was rejected.

**One row was briefly UNPINNED, and the state was cleared by deletion.**
`PXD022216/200723_CLL_library_direct.tsv` had been fetched while spectral
libraries were still assigned to `default` depth. When the depth rules moved
them to the bulk tier, the `default`-depth run no longer covered the file, so
its row stayed `PENDING` while the bytes sat on disk — the `UNPINNED` state:
bytes present that the manifest has never recorded. The alternative to deleting
it was `./DOWNLOAD.sh raw`, which would have pinned it but also started the full
583.3 GiB retrieval. On 2026-08-21 the file was deleted at the maintainer's
direction, returning its row to `NOT_YET_DOWNLOADED`, and `./DOWNLOAD.sh raw`
will fetch it again with a pin. No manifest row was edited to clear the state.
The counts computed from that copy are kept in README.md and labelled as
measurements from bytes no longer held.

`MANIFEST.tsv` is not self-verifying. Its integrity rests on three things
outside it: version control history, the saved upstream artifacts under
`provenance/upstream/`, and the structural validation `DOWNLOAD.sh` performs on
every read. If this chain must hold up to someone other than the maintainer,
signed commits or a signed tag are the only anchor an in-directory file cannot
provide.

## Retrieval record

| Field | Value |
| --- | --- |
| Date retrieved | Metadata and upstream checksums: 2026-08-20. Data files: the 7 `default`-depth files pinned 2026-08-20; all were already on disk, having been fetched earlier the same day, and were verified against their publisher SHA-1 rather than re-transferred. The 187 `raw`-depth files are not retrieved |
| Retrieved by | iandirk.fichtner@dkfz-heidelberg.de |
| `curl` version | curl 8.11.1 (x86_64-redhat-linux-gnu), libcurl/8.11.1 OpenSSL/3.2.6, release date 2024-12-11 |
| `sha256sum` version | sha256sum (GNU coreutils) 9.6 |
| Other tools | sha1sum (GNU coreutils) 9.6; GNU bash 5.2.37(1); git 2.51.0; python3 3.13 (manifest generation, JSON parsing, and `scripts/matrix_stats.py`); Linux 6.19.12-100.fc42.x86_64. `shellcheck` is **not installed**, so the static-lint check in `TEST_DOWNLOAD.sh` reports SKIP rather than passing |

Sources read for the descriptive prose in these documents, all fetched
successfully on 2026-08-20 and listed with their HTTP status in
`provenance/upstream/FETCH_LOG.tsv`: both PRIDE project records, both
ProteomeXchange PROXI records, the three PRIDE file-metadata pages, both archive
directory listings, and the Europe PMC record for PMID 34189564. The article's
Methods, author list and data-sharing statement were read from the
publisher-formatted PDF at
`https://www.huber.embl.de/pub/pdf/Meier-Abt-Blood-2021.pdf` (HTTP 200, 25
pages, 6 670 044 bytes), because `ashpublications.org` and the Queen's
University Belfast repository copy both returned HTTP 403 to this session. That
PDF is a third-party mirror, so treat quotations from it as sourced to a mirror
rather than to the publisher of record.

## Manually obtained files

Files held in this directory that `DOWNLOAD.sh` cannot retrieve. They are not
in `MANIFEST.tsv`, because the manifest lists only files the script can fetch
and re-verify, and they are git-ignored like the deposit data. The checksum
below is the only integrity record: compare a copy against it with
`sha256sum supplementary-data/bloodbld2020009741-suppl1.pdf`.

| Field | Value |
| --- | --- |
| Path | `supplementary-data/bloodbld2020009741-suppl1.pdf` |
| What it is | Supplement 1 of Meier-Abt et al., *Blood* 2021 (doi:10.1182/blood.2020009741): 30-page PDF with Figures S1–S24 and Tables S1–S3 |
| Why it is held | Table S1, "Patient characteristics", gives one row per patient (ID, age, sex, IGHV status, trisomy 12, WBC count, survival, treatment, cohort, batch); Tables S2 and S3 summarise the main and additional cohorts. The `batch` column matches the Batch column of `PXD022198/Annotation_file.csv`, which makes this the clinical key for the patient runs |
| Bytes | 3323551 |
| sha256 | `3931ec29a56c6808711bd6cd121042a87cb78cae8494ec15c936769cf84f9646` |
| Obtained | 2026-08-23 (file modification time), by hand from the publisher's article page |
| Source | `https://ashpublications.org/blood/article/138/24/2514/476272/The-protein-landscape-of-chronic-lymphocytic`, Supplementary data section |
| Why not automated | Checked 2026-10-19: the DOI and the article page return HTTP 403 with a Cloudflare JavaScript challenge, to curl and to a browser user agent alike; the file's CDN path (`ash.silverchair-cdn.com/…/bloodbld2020009741-suppl1.pdf`) returns HTTP 403 `MissingKey`, because it serves only expiring signed links issued by that page; Europe PMC holds no supplementary files for the article (HTTP 404). There is no stable URL for a script to re-fetch |
| License | Not covered by the deposits' CC0. The article is not open access (Europe PMC: `isOpenAccess: N`, `license: null`), so the file is not redistributed with this repository |

## Not downloaded

- **Depth `raw`: 187 files, 583.3 GiB.** The 185 raw MS acquisitions
  (50 `.d.zip` from PXD022216, 135 `.raw` from PXD022198), the exported
  Spectronaut spectral library, and the 24.2 GiB `.sne` session archive. Fetch
  with `./DOWNLOAD.sh raw`; at the archive's observed ~1.8 MB/s that is a
  multi-day transfer. A first attempt on the `.sne` was cancelled after 1.2 GiB
  of 24.2 GiB; `DOWNLOAD.sh` removed its temporary file on exit and left no
  partial or stub behind, and the file was then reclassified from `default` to
  `raw` along with the spectral library. The library itself was fetched before
  that reclassification and has since been deleted, so nothing at `raw` depth is
  held. Its content counts survive in README.md, labelled as computed from bytes
  no longer present.
- **The DNA-sequencing, RNA-sequencing and ex vivo drug-response layers**
  integrated in the paper, distributed per the article in the Bioconductor data
  package `BloodCancerMultiOmics2017`. Not part of either PRIDE deposit and not
  covered by this manifest.
- **The published analysis code**, at
  `https://github.com/Huber-group-EMBL/CLLproteomics` and the accompanying
  Rmarkdown workflow site. Both URLs are UNVERIFIED: transcribed from the
  article, not fetched during this session. Code, not data.

## Unverified

**Resolved on 2026-08-21 from the `default`-depth files**, recorded here so the
trail from question to answer stays visible:

- *Technical replicate design* — **resolved.** `PXD022198/Annotation_file.csv`
  lists 117 sample runs against 117 distinct Patient IDs and 117 distinct Sample
  IDs; `PXD022216/Annotation_file_timsTOF.txt` lists 50 runs against 50 distinct
  Patient IDs, Sample IDs and pseudonyms. No technical replicates among the
  deposited sample runs, and the `_rep` suffix is not a replicate marker.
- *Meaning of the `L1`–`L6` and `Pool1`–`Pool6` run names* — **resolved.** The
  annotation file's third table is headed "Library files" and names exactly those
  18 runs. They are spectral-library acquisitions, not patient samples, and
  appear in none of the three quantification reports. 117 samples + 18 library
  runs = the 135 deposited `.raw` files, with nothing left over.
- *Missing-value convention, and whether zero means "not quantified"* —
  **resolved.** `NaN` in four of the five quantitative files; no null token at
  all in the precursor report, where a missing cell is an absent row; no empty
  field anywhere; and no value equal to zero in any quantity column, so the zero
  ambiguity cannot affect any completeness figure. Neither PRIDE record states
  any of this — it was counted.
- *Encoding, delimiter and line terminator* — **resolved for the 7 downloaded
  files** (see README.md). Still unobserved for the 187 `raw`-depth files.
- *Search database version for PXD022216* — **resolved, and it was not on the
  original list.** All 786 266 rows of the exported spectral library name
  `FASTAName = uniprot_sprot_2020-01-01_HUMAN` and `Database = sp`, confirming
  from the data the version the PRIDE record states.
- *Batch-to-filename mapping* — **resolved.** batch1 = the 49 `20191016_*` runs,
  batch2 = the 42 `…CD19selected…` runs, batch3 = the 26 `…screen2…` runs.

Still open:

- **Normalization state of four of the five quantitative files** — one is settled
  by its own filename (`…ProteinQuant_normalReport.csv` is Spectronaut's
  normalised export). For the PXD022216 precursor and protein reports and the
  other two PXD022198 reports, neither PRIDE record states whether Spectronaut's
  internal normalisation was enabled, and the exports carry no column recording
  it. Options: (a) fetch the `.sne` session archive at `raw` depth and read its
  Spectronaut settings; (b) compare per-run intensity distributions for the
  signature of normalisation; (c) ask the submitter.
- **Why the deposited protein report does not reproduce the paper's 4 977
  proteins** — the article states that filtering to proteins with fewer than 50%
  missing values across the 49 retained timsTOF samples left 4 977 proteins.
  Applying that filter to the deposited protein report gives 4 944 when the run
  with the fewest quantified protein groups is dropped, and every one of the 50
  possible single-run exclusions lands between 4 932 and 4 946. Options: (a) read
  the published analysis code and record which table it starts from; (b) re-derive
  protein quantities from the precursor report and re-test; (c) leave the
  discrepancy recorded and use the deposited table as it stands.
- **Whether the 34 runs quantified but never deposited are recoverable** — the
  three PXD022198 reports quantify 151 distinct runs; only 117 exist as `.raw`
  files here, and the annotation file's closing line says only files meeting the
  quality criteria were uploaded. Options: (a) accept the 117 and drop the other
  34 columns; (b) ask the submitter whether the excluded acquisitions still
  exist; (c) analyse the reports at full width, documenting that 34 columns have
  no raw provenance in this deposit.
- **Encoding and contents of the 186 `raw`-depth files never inspected** — not
  downloaded, so nothing about their bytes has been observed. The 187th, the
  spectral library, was inspected before deletion and its counts are recorded.
  Options: (a) `./DOWNLOAD.sh raw`; (b) fetch a single file by editing a one-row
  manifest copy and pointing `--manifest` at it; (c) leave them unobserved,
  which is the current scoping decision.
- **Whether PRIDE considers the 4096-byte `Pool6` file a known defect** — sought
  in the deposit's revision history and changelog entries, which mention only
  metadata updates. Options: (a) report it to `pride-support@ebi.ac.uk` and
  record the ticket here; (b) ask the submitting authors for the original file;
  (c) proceed without it and document the gap in any analysis.
- **Reachability of the two URLs transcribed from the article** — the *Blood*
  article page and the analysis-code repository. The *Blood* page returned HTTP
  403; the repository was not requested. Options: (a) open them in a browser and
  confirm, then drop the marker; (b) leave them marked, since neither is needed
  to retrieve or verify the data; (c) replace the article link with the DOI
  `10.1182/blood.2020009741`.

## Manifest changelog

One row per change to `MANIFEST.tsv`, each tied to the commit that made it.
`git log -p MANIFEST.tsv` is authoritative; this table is the readable summary.

| Date | Commit | Change | Reason |
| --- | --- | --- | --- |
| 2026-08-21 | `a92c1f6` | Created with 194 Tier A rows covering PXD022216 (55) and PXD022198 (139), all in the planned state: `bytes`, `sha256` and `pinned_date` all `PENDING`. Depths assigned: 7 `default`, 0 `supplementary`, 187 `raw`. Upstream SHA-1 values transcribed from three PRIDE v3 file-metadata API pages saved under `provenance/upstream/` | Initial documentation of the deposits, committed before any download so that the plan and the observation are separately attributable |
| 2026-08-21 | `366e5d3` | `bytes`, `sha256` and `pinned_date` written for the 7 `default`-depth rows. No other field changed on any row | The `default`-depth files were verified against their publisher SHA-1, so their local observations became recordable |
| 2026-10-19 | `8a37a3b` | `bytes`, `sha256` and `pinned_date` written for the 117 patient-sample runs of PXD022198 (batch1 49, batch2 42, batch3 26), pinned 2026-10-13/14. Only those three fields changed, each from `PENDING` | The runs were retrieved with `./DOWNLOAD_PATIENT_RUNS.sh` and passed their publisher SHA-1, on a different machine; every pinned size equals the size PRIDE states |
| 2026-10-19 | `d34e5e1` | `up_bytes` column inserted after `pinned_date`, filled for all 194 rows from `fileSizeBytes` in the saved PRIDE v3 file records. No other field changed | The dataset-documentation skill's manifest format gained the column on 2026-08-25; it records the source-stated size, which a Tier B row is checked against and the depth totals are computed from |
