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
| Supplementary tables and figures of the *Blood* article | no | n/a | Journal-published analysis results, not primary data, and behind the publisher's paywall. Excluded at the user's direction |
| DNA-seq, RNA-seq and ex vivo drug-response layers | no | n/a | Not part of either deposit. The article states they were generated previously and are distributed in the Bioconductor package `BloodCancerMultiOmics2017` |
| Published analysis code and Rmarkdown workflows | no | n/a | Code, not data. URLs transcribed from the article's data-sharing statement and left UNVERIFIED |
| PRIDE Aspera transfer endpoints | no | n/a | An alternative transport for the same bytes, not a separate source. `DOWNLOAD.sh` uses HTTPS only, so the manifest records only HTTPS URLs |

Depths actually downloaded so far: none, on no date. Everything remains planned
— every manifest row is `PENDING` and `./DOWNLOAD.sh <depth>` will fetch it.

## File descriptions

Descriptions only — paths, sizes, and checksums live in `MANIFEST.tsv`. A file
whose name already says what it is gets no row here.

| Path | Description | Description source |
| --- | --- | --- |
| `PXD022216/fmeierab_T190525_CLL_diaPASEF_*.d.zip` | Zipped Bruker `.d` acquisition folders, timsTOF Pro, standard diaPASEF. 50 runs, numbered 01–50 contiguously with a trailing four-digit run id. Primary measurements of this deposit | PRIDE file category "Associated raw file URI"; acquisition mode from the PXD022216 sample-processing protocol and the article Methods |
| `PXD022216/200723_CLL_library_direct.tsv` | Spectronaut spectral library exported for the direct (DIA-only) library used to search this deposit | PRIDE file category "Other type file URI"; library construction described in the PXD022216 data-processing protocol |
| `PXD022216/20200727_103309_200725_cll_diaPASEF_direct_Report_Peptide_long.tsv` | Spectronaut peptide/precursor-level report, long format: one row per precursor per run, carrying protein-group identifiers alongside the precursor quantity | PRIDE file category "Search engine output file URI"; Spectronaut export described in the PXD022216 data-processing protocol |
| `PXD022216/20200727_104510_200725_cll_diaPASEF_direct_Report_Protein_long.tsv` | Spectronaut protein-level report, long format, companion to the precursor report above | PRIDE file category "Search engine output file URI" |
| `PXD022216/20200727_105729_200725_cll_diaPASEF_direct.sne` | Spectronaut session archive for the direct-library search of this deposit: the analysis workspace, coupled to the Spectronaut release that wrote it (v14.4), not a portable results table. Its export timestamp places it in the same batch as the two long-format reports — `20200727_103309`, `20200727_104510`, `20200727_105729`, all carrying the `200725_cll_diaPASEF_direct` analysis name | PRIDE file category "Other type file URI"; export batch inferred from the filename timestamps; that `.sne` is Spectronaut's session format is general knowledge about the format, not a statement either PRIDE record makes |
| `PXD022216/Annotation_file_timsTOF.txt` | Experimental-design annotation: the upstream mapping from timsTOF MS run to patient sample | PRIDE file category "Experimental design file URI" |
| `PXD022198/20191016_0??_S*_CLL_*.raw` | Thermo Orbitrap Fusion Lumos raw acquisitions, acquisition batch dated 2019-10-16, sample runs carrying an `S`-prefixed internal specimen id and a `CLL_<n>` index; 5 of the 49 also carry a `_rep` suffix | PRIDE file category "Associated raw file URI"; filename structure observed in the deposit listing |
| `PXD022198/20191016_0?_L?*.raw` | Thermo Orbitrap Fusion Lumos raw acquisitions from the same 2019-10-16 batch whose names carry `L1`–`L6` instead of a specimen id. UNVERIFIED: neither PRIDE record states what `L` denotes | PRIDE file category "Associated raw file URI"; filename structure observed in the deposit listing |
| `PXD022198/20201112_*_CLL_screen2_[0-9]*_Diseased.raw` | Lumos raw acquisitions, batch dated 2020-11-12, `screen2` sample runs with a numeric sample index | PRIDE file category "Associated raw file URI"; filename structure observed in the deposit listing |
| `PXD022198/20201112_*_CLL_screen2_Pool*_Diseased.raw` | Lumos raw acquisitions from the same 2020-11-12 batch whose names carry `Pool1`–`Pool6`. UNVERIFIED: neither PRIDE record states what is pooled | PRIDE file category "Associated raw file URI"; filename structure observed in the deposit listing |
| `PXD022198/20210107_*_CLL_CD19selected_[0-9]*_Diseased.raw` | Lumos raw acquisitions, batch dated 2021-01-07, CD19-selected sample runs with a numeric sample index | PRIDE file category "Associated raw file URI"; CD19 selection described in the PXD022198 sample-processing protocol and the article Methods |
| `PXD022198/20210107_*_CLL_CD19selected_Pool*.raw` | Lumos raw acquisitions from the same 2021-01-07 CD19-selected batch whose names carry `Pool1`–`Pool6`. Same UNVERIFIED caveat on `Pool` as above. **`20210107_003_S281243_CLL_CD19selected_Pool6.raw` is defective upstream** — see the integrity record below | PRIDE file category "Associated raw file URI"; filename structure observed in the deposit listing |
| `PXD022198/20201112_p3254_o23219_CLLsample_library_ProteinQuant_Report.csv` | Spectronaut protein-quantification report for the CLL-sample library | PRIDE file category "Search engine output file URI" |
| `PXD022198/20201207_p3254_o20368_hybrid_library_min2proteotypicPeptides_ProteinQuant_normalReport.csv` | Spectronaut protein-quantification report for the hybrid (DDA+DIA) library, restricted to proteins with at least two proteotypic peptides — the quantification rule stated in the deposit's data-processing protocol. The `normalReport` element of the name marks it as Spectronaut's normalised export | PRIDE file category "Search engine output file URI"; the ≥2-proteotypic-peptide rule from the PXD022198 data-processing protocol |
| `PXD022198/20210117_p3254_o23722_CD19selected_Library_ProteinQuant_Report.csv` | Spectronaut protein-quantification report for the CD19-selected library | PRIDE file category "Search engine output file URI" |
| `PXD022198/Annotation_file.csv` | Experimental-design annotation: the upstream mapping from Lumos MS run to patient sample | PRIDE file category "Other type file URI"; role inferred from its name and from the equivalent file in PXD022216, which PRIDE labels "Experimental design file URI" |

The description source is either a named upstream document, or
`derived: <what was inspected>` for a description read off the file itself after
download — a header row, an archive listing, a column dictionary inside the file.
Keep the two distinct: what the publisher says a file is and what the bytes show
it to be are different claims, and they occasionally disagree. At this baseline
every description is upstream-sourced, because nothing has been downloaded.

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
received. At this baseline all 194 rows are `PENDING` in `bytes`, `sha256` and
`pinned_date` — the three move as a unit, written together by `DOWNLOAD.sh`
after a file passes its tier gate. That is the only manifest mutation the script
performs outside `--refresh-manifest`, it touches only those three columns, and
it never turns a populated pin into a different one without `--force`.

`MANIFEST.tsv` is not self-verifying. Its integrity rests on three things
outside it: version control history, the saved upstream artifacts under
`provenance/upstream/`, and the structural validation `DOWNLOAD.sh` performs on
every read. If this chain must hold up to someone other than the maintainer,
signed commits or a signed tag are the only anchor an in-directory file cannot
provide.

## Retrieval record

| Field | Value |
| --- | --- |
| Date retrieved | Metadata and upstream checksums: 2026-08-20. Data files: none retrieved at this baseline |
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

## Not downloaded

- **Everything.** At this baseline no data file has been retrieved; all 194
  manifest rows are `PENDING`. `./DOWNLOAD.sh` fetches the 7 `default`-depth
  files (552.2 MiB); `./DOWNLOAD.sh raw` fetches all 194 (583.9 GiB), which at
  the archive's observed ~1.8 MB/s is a multi-day transfer.
- **The article's supplementary tables and figures.** Analysis results, not
  primary data, and deliberately out of scope. They are on the *Blood* article
  page at
  `https://ashpublications.org/blood/article/138/24/2514/476272/The-protein-landscape-of-chronic-lymphocytic`,
  which is UNVERIFIED: the publisher returned HTTP 403 to every automated
  request from this session, so the URL was not fetched and its reachability is
  not confirmed here.
- **The DNA-sequencing, RNA-sequencing and ex vivo drug-response layers**
  integrated in the paper, distributed per the article in the Bioconductor data
  package `BloodCancerMultiOmics2017`. Not part of either PRIDE deposit and not
  covered by this manifest.
- **The published analysis code**, at
  `https://github.com/Huber-group-EMBL/CLLproteomics` and the accompanying
  Rmarkdown workflow site. Both URLs are UNVERIFIED: transcribed from the
  article, not fetched during this session. Code, not data.

## Unverified

- **Technical replicate design** — sought in both PRIDE project records
  (`sampleProcessingProtocol`, `dataProcessingProtocol`, `additionalAttributes`)
  and in the article Methods and Figure 1 legend. No technical-replicate count
  is stated anywhere. Options: (a) download `default` depth and read the design
  off the two annotation files; (b) ask the corresponding authors; (c) treat
  every run as independent until the annotation says otherwise.
- **Meaning of the `L1`–`L6` and `Pool1`–`Pool6` run names in PXD022198** —
  sought in the PRIDE project description and protocols and in the article
  Methods. Not documented. Options: (a) read the annotation file at `default`
  depth; (b) inspect the acquisition method inside one such `.raw` after a `raw`
  download; (c) ask the submitter.
- **Missing-value convention, and whether zero means "not quantified"** — sought
  in both PRIDE data-processing protocols and in the article Methods. Not
  stated. Options: (a) establish it from the files once downloaded and record it
  beside the statistics; (b) report completeness both ways with the ambiguity
  named; (c) ask the submitter.
- **Normalization state of the deposited Spectronaut exports** — one file names
  it in its own filename; for the rest, neither record states whether
  Spectronaut's internal normalisation was enabled. Options: (a) inspect the
  Spectronaut settings inside the `.sne` session archive at `raw` depth;
  (b) compare per-run intensity distributions once the reports are downloaded;
  (c) ask the submitter.
- **Encoding, delimiter and line terminator of every deposited file** — not
  stated in either PRIDE record. Options: (a) observe them after download and
  record them; (b) leave unstated; (c) ask the submitter.
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
| 2026-08-21 | baseline | Created with 194 Tier A rows covering PXD022216 (55) and PXD022198 (139), all in the planned state: `bytes`, `sha256` and `pinned_date` all `PENDING`. Depths assigned: 7 `default`, 0 `supplementary`, 187 `raw`. Upstream SHA-1 values transcribed from three PRIDE v3 file-metadata API pages saved under `provenance/upstream/` | Initial documentation of the deposits, committed before any download so that the plan and the observation are separately attributable |
