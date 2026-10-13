#!/usr/bin/env bash
# DOWNLOAD_PATIENT_RUNS.sh — retrieve and verify only the 117 CLL patient-sample
# acquisitions of PRIDE PXD022198 (Thermo Orbitrap Fusion Lumos), the cohort the
# article analyses, and nothing else at `raw` depth.
#
# Usage:
#   ./DOWNLOAD_PATIENT_RUNS.sh [options]
#
#   Examples:
#     ./DOWNLOAD_PATIENT_RUNS.sh                  fetch the 117 patient runs
#     ./DOWNLOAD_PATIENT_RUNS.sh --dry-run        plan them, write nothing
#     ./DOWNLOAD_PATIENT_RUNS.sh --verify-only    check them on disk, no network
#     ./DOWNLOAD_PATIENT_RUNS.sh --help           full option list
#
# What it selects:
#   The sample rows of PXD022198/Annotation_file.csv, i.e. every row of its
#   "Exploratory cohort" and "Additional cohort" tables whose Batch column is
#   batch1, batch2 or batch3: 49 + 42 + 26 = 117 runs, one per patient. The
#   selection is read from the annotation file at run time, never from a list
#   in this script, and is asserted to resolve to exactly 117 MANIFEST.tsv rows.
#   Left out: the 18 spectral-library runs of PXD022198 (the annotation file's
#   "Library files" table, which carries no Batch), the whole timsTOF deposit
#   PXD022216, the exported spectral library and the .sne session archive.
#   ./DOWNLOAD.sh raw fetches all of those.
#
# How it works:
#   This script retrieves nothing itself. It writes a filtered copy of
#   MANIFEST.tsv holding only the 117 rows, in a temporary directory outside
#   this one, runs ./DOWNLOAD.sh raw against it with --manifest, and so inherits every check
#   DOWNLOAD.sh makes: the manifest gate, the per-file Tier A SHA-1 gate against
#   PRIDE, the temp-file-then-atomic-mv install, chmod a-w, and the exit codes.
#   After a download run it merges the pins DOWNLOAD.sh wrote into the filtered
#   copy back into MANIFEST.tsv, under the same rule DOWNLOAD.sh follows: only
#   fields 4-6 (bytes, sha256, pinned_date), all three together, only ever
#   PENDING -> observed unless --force says the file was genuinely re-fetched,
#   via a temp file and an atomic mv. It never touches an upstream column and
#   never touches git. The merge also runs when the download is interrupted, so
#   a file that completed before the interruption is never left UNPINNED; if it
#   ever is, the next run pins it from disk after re-checking its SHA-1.
#
# Preconditions:
#   PXD022198/Annotation_file.csv must be on disk and match its MANIFEST.tsv
#   pin, because it is what the selection is read from. ./DOWNLOAD.sh fetches
#   it (depth default).
#
# Source        : PRIDE Archive / ProteomeXchange, PXD022198
#                 https://www.ebi.ac.uk/pride/archive/projects/PXD022198
# License       : Creative Commons Public Domain (CC0) — see PROVENANCE.md.
# Credentials   : none. This script reads no credential environment variables.
# Download size : 117 x .raw, ~330.4 GiB (batch1 ~135.5, batch2 ~128.1,
#                 batch3 ~66.8 GiB), from the PRIDE file records saved under
#                 provenance/upstream/. At the archive's ~1.8 MB/s this is a
#                 multi-day transfer; an interrupted run resumes file by file.
#
# Exit codes are DOWNLOAD.sh's: 0 success, 1 verification failure (including a
# missing or unpinned annotation file), 2 usage error, 3 manifest structural
# error (including a selection that does not resolve to exactly 117 rows),
# 4 retrieval failure.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DL="$SCRIPT_DIR/DOWNLOAD.sh"
MANIFEST="$SCRIPT_DIR/MANIFEST.tsv"
ROOT="$SCRIPT_DIR"

ANNOTATION_REL='PXD022198/Annotation_file.csv'
EXPECTED_RUNS=117
PENDING='PENDING'

do_help=0
do_list_flags=0
do_dry_run=0
do_verify_only=0
do_force=0

SUBSET_DIR=''
SUBSET=''
finish() {
  local st=$?
  trap - EXIT INT TERM
  if [[ -n "$SUBSET" && -e "$SUBSET" && $do_dry_run -eq 0 && $do_verify_only -eq 0 ]]; then
    if ! merge_pins; then
      warn "pin merge failed; the subset manifest is kept for inspection: $SUBSET"
      SUBSET_DIR=''
      [[ $st -ne 0 ]] || st=3
    fi
  fi
  [[ -n "$SUBSET_DIR" && -d "$SUBSET_DIR" ]] && rm -rf -- "$SUBSET_DIR"
  exit "$st"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

log()  { printf '%s  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"; }
warn() { printf '%s  WARN  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }
die()  { local code="$1"; shift; printf 'ERROR: %s\n' "$*" >&2; exit "$code"; }

usage() {
  cat <<'USAGE'
DOWNLOAD_PATIENT_RUNS.sh — retrieve and verify the 117 CLL patient-sample runs
of PRIDE PXD022198 (Orbitrap Fusion Lumos), and nothing else.

Usage: DOWNLOAD_PATIENT_RUNS.sh [options]

Selects the sample rows of PXD022198/Annotation_file.csv (Batch = batch1,
batch2 or batch3): 117 .raw files, about 330.4 GiB. Leaves out the 18 PXD022198
spectral-library runs and everything in PXD022216. Delegates every retrieval
and check to ./DOWNLOAD.sh raw, then records the pins in MANIFEST.tsv.

There is no DEPTH argument: the selection is fixed. Use ./DOWNLOAD.sh for depth
selection, --refresh-manifest, --emit-sha256sums and --manifest.

Options:
  --help                print this message and exit 0
  --list-flags          print flag<TAB>arity pairs and exit 0
  --dry-run             resolve and report every planned action, write nothing
  --verify-only         check the 117 local files against the manifest; no network, no writes
  --force               re-download even when the checksum matches
  --root PATH           destination root for the layout (default: alongside this script)

Exit codes (those of DOWNLOAD.sh):
  0 success
  1 verification failure, or the annotation file is absent or fails its pin
  2 usage error
  3 manifest structural error, or the selection is not exactly 117 rows
  4 retrieval failure
USAGE
}

list_flags() {
  printf '%s\t%s\n' \
    --help novalue \
    --list-flags novalue \
    --dry-run novalue \
    --verify-only novalue \
    --force novalue \
    --root value
}

# ------------------------------------------------------------ argument parse ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)        do_help=1 ;;
    --list-flags)  do_list_flags=1 ;;
    --dry-run)     do_dry_run=1 ;;
    --verify-only) do_verify_only=1 ;;
    --force)       do_force=1 ;;
    --root)
      [[ $# -ge 2 ]] || die 2 "--root requires a PATH argument"
      ROOT="$2"; shift ;;
    --manifest|--refresh-manifest|--force-pin|--emit-sha256sums)
      die 2 "$1 acts on the whole manifest; use ./DOWNLOAD.sh for it" ;;
    -*) die 2 "unknown flag: $1 (try --help)" ;;
    *)  die 2 "unexpected argument '$1': the selection is fixed, there is no DEPTH (use ./DOWNLOAD.sh for depths)" ;;
  esac
  shift
done

if [[ $do_help -eq 1 ]]; then usage; exit 0; fi
if [[ $do_list_flags -eq 1 ]]; then list_flags; exit 0; fi

if [[ $do_dry_run -eq 1 && $do_force -eq 1 ]]; then
  die 2 "--dry-run and --force are mutually exclusive"
fi
if [[ $do_verify_only -eq 1 && ( $do_force -eq 1 || $do_dry_run -eq 1 ) ]]; then
  die 2 "--verify-only cannot be combined with --force or --dry-run"
fi

for t in awk date mktemp sha256sum; do
  command -v "$t" >/dev/null 2>&1 || die 4 "required tool not found: $t (install it and retry)"
done
[[ -f "$DL" && -r "$DL" ]] || die 3 "DOWNLOAD.sh not found next to this script: $DL"
[[ -f "$MANIFEST" && -r "$MANIFEST" && -s "$MANIFEST" ]] || die 3 "manifest missing, unreadable or empty: $MANIFEST"

# ---------------------------------------------------- annotation precondition ---
# The selection is only as trustworthy as the file it is read from, so that file
# must be the pinned bytes, checked here against its MANIFEST.tsv sha256.
ANNOTATION="$ROOT/$ANNOTATION_REL"
ann_pin="$(awk -F'\t' -v p="$ANNOTATION_REL" 'NR > 1 && $1 == p { print $5; exit }' "$MANIFEST")"
[[ -n "$ann_pin" ]] || die 3 "MANIFEST.tsv has no row for $ANNOTATION_REL"
[[ "$ann_pin" != "$PENDING" ]] || \
  die 1 "$ANNOTATION_REL is not pinned yet; run ./DOWNLOAD.sh first (depth default) — the selection is read from it"
[[ -f "$ANNOTATION" ]] || \
  die 1 "$ANNOTATION is absent although pinned; run ./DOWNLOAD.sh (with the same --root) to restore it"
ann_got="$(sha256sum -- "$ANNOTATION" | awk '{print $1}')"
[[ "$ann_got" == "$ann_pin" ]] || \
  die 1 "$ANNOTATION does not match its MANIFEST.tsv sha256 pin; refusing to select from it (./DOWNLOAD.sh --verify-only)"

# ------------------------------------------------------------------ selection ---
# Sample rows are those whose 6th field, Batch, is batch1|batch2|batch3. Both
# cohort tables put Batch in column 6; that is asserted on every "File name"
# header row rather than assumed. Batch-1 run names carry no .raw suffix in the
# annotation file and batch 2/3 names do, so the suffix is normalised.
SELECTION="$(awk -F';' '
  { sub(/\r$/, "") }
  $1 == "File name" {
    if ($6 != "Batch") { printf "header row %d has \"%s\" in column 6, expected \"Batch\"\n", NR, $6 > "/dev/stderr"; bad = 1 }
    hdr++; next
  }
  $6 ~ /^batch[123]$/ {
    n = $1; if (n !~ /\.raw$/) n = n ".raw"
    print "PXD022198/" n
  }
  END { if (hdr != 2) { printf "expected 2 cohort header rows, found %d\n", hdr > "/dev/stderr"; bad = 1 }
        if (bad) exit 1 }
' "$ANNOTATION")" || die 3 "$ANNOTATION_REL is not laid out as expected (see above)"

# The subset manifest lives outside the data directory, so --dry-run and
# --verify-only leave this directory exactly as they found it.
SUBSET_DIR="$(mktemp -d)"
SUBSET="$SUBSET_DIR/MANIFEST.tsv"
counts="$(printf '%s\n' "$SELECTION" | awk -F'\t' -v out="$SUBSET" '
  NR == FNR { if ($0 != "") { if (want[$0]++) dup++; nsel++ } ; next }
  FNR == 1  { print > out; next }
  $1 in want { print > out; found[$1] = 1; nrow++ }
  END {
    for (p in want) if (!(p in found)) { printf "no MANIFEST.tsv row for %s\n", p > "/dev/stderr"; miss++ }
    printf "%d %d %d %d\n", nsel, nrow, dup + 0, miss + 0
  }
' - "$MANIFEST")"
IFS=' ' read -r nsel nrow ndup nmiss <<<"$counts"
if [[ "$nsel" -ne $EXPECTED_RUNS || "$nrow" -ne $EXPECTED_RUNS || "$ndup" -ne 0 || "$nmiss" -ne 0 ]]; then
  die 3 "selection does not resolve to exactly $EXPECTED_RUNS manifest rows: $nsel annotation rows, $nrow manifest rows, $ndup duplicate, $nmiss unmatched"
fi
log "selected $nrow patient-sample runs from $ANNOTATION_REL (annotation matches its pin)"

# ------------------------------------------------------------------ pin merge ---
# Copy the local-observation triple of each subset row back into MANIFEST.tsv.
# Same rule as DOWNLOAD.sh's write_pin: fields 4-6 only, all three together,
# PENDING -> observed, and a populated pin moves only under --force. When
# nothing changes, MANIFEST.tsv is not rewritten at all.
merge_pins() {
  local tmp was_ro=0 summary
  tmp="$(mktemp "$SCRIPT_DIR/.MANIFEST.XXXXXXXX")"
  chmod 0644 "$tmp"
  summary="$(awk -F'\t' -v OFS='\t' -v out="$tmp" -v force="$do_force" -v pend="$PENDING" '
    NR == FNR {
      if (FNR > 1 && $4 != pend && $5 != pend && $6 != pend) { b[$1] = $4; h[$1] = $5; d[$1] = $6 }
      next
    }
    FNR == 1 { print > out; next }
    ($1 in h) && $5 != h[$1] {
      if ($5 == pend || force == 1) { $4 = b[$1]; $5 = h[$1]; $6 = d[$1]; moved++ }
      else { printf "kept the existing pin of %s; --force is required to move it\n", $1 > "/dev/stderr"; kept++ }
    }
    { print > out }
    END { printf "%d %d\n", moved + 0, kept + 0 }
  ' "$SUBSET" "$MANIFEST")" || { rm -f "$tmp"; return 1; }
  local moved kept
  IFS=' ' read -r moved kept <<<"$summary"
  if [[ "$moved" -eq 0 ]]; then
    rm -f "$tmp"
    log "MANIFEST.tsv unchanged: no new pins to record"
    return 0
  fi
  [[ -w "$MANIFEST" ]] || was_ro=1
  mv -f "$tmp" "$MANIFEST"
  [[ $was_ro -eq 1 ]] && chmod a-w "$MANIFEST"
  log "recorded $moved pin(s) in MANIFEST.tsv; $kept existing pin(s) kept unchanged"
  printf 'MANIFEST.tsv gained %d pin(s). Commit it on its own:\n' "$moved"
  printf "  git add MANIFEST.tsv && git commit -m 'data(cll-proteomics): pin %d patient-sample raw files of PXD022198'\n" "$moved"
  return 0
}

# ---------------------------------------------------------------------- main ---
args=(raw --manifest "$SUBSET" --root "$ROOT")
[[ $do_dry_run -eq 1 ]]     && args+=(--dry-run)
[[ $do_verify_only -eq 1 ]] && args+=(--verify-only)
[[ $do_force -eq 1 ]]       && args+=(--force)

st=0
bash "$DL" "${args[@]}" || st=$?
exit "$st"
