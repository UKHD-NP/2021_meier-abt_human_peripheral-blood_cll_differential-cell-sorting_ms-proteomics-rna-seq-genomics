#!/usr/bin/env bash
# DOWNLOAD.sh — retrieve and verify the CLL DIA-MS proteomics deposits
# PXD022216 (timsTOF Pro, diaPASEF) and PXD022198 (Orbitrap Fusion Lumos)
# from the PRIDE Archive at EMBL-EBI.
#
# Usage:
#   ./DOWNLOAD.sh [DEPTH] [options]
#
#   DEPTH is an optional positional argument, at most one, default `default`.
#   Depths are cumulative: default <= supplementary <= raw. Every MANIFEST.tsv
#   row carries its own `depth`, and the positional selects the row set that
#   every mode acts on -- download, --dry-run, --verify-only,
#   --refresh-manifest, --emit-sha256sums. Rows outside the requested depth are
#   reported as out-of-scope, never as missing.
#
#     default        core processed files: the Spectronaut precursor and protein
#                    reports, the three per-batch protein-quantification
#                    reports, and both experimental-design annotation files.
#                    7 files, ~552 MiB.
#     supplementary  default plus supplementary and secondary files. Neither
#                    deposit contains any, so this resolves to the same 7 files.
#                    The article's supplementary tables are journal-published
#                    analysis results, not deposited data, and are out of scope
#                    (see PROVENANCE.md).
#     raw            supplementary plus raw instrument files and bulk inputs:
#                    the 185 raw MS acquisitions, the exported Spectronaut
#                    spectral library, and the Spectronaut .sne session
#                    archive. 194 files, ~583.9 GiB.
#
#   Examples:
#     ./DOWNLOAD.sh                    core processed files
#     ./DOWNLOAD.sh raw                the whole deposit
#     ./DOWNLOAD.sh raw --dry-run      plan the whole deposit, write nothing
#     ./DOWNLOAD.sh --verify-only      check the core files, no network
#     ./DOWNLOAD.sh raw --verify-only  check everything on disk
#     ./DOWNLOAD.sh --help             full option list
#
# Source        : PRIDE Archive / ProteomeXchange
#                 https://www.ebi.ac.uk/pride/archive/projects/PXD022216
#                 https://www.ebi.ac.uk/pride/archive/projects/PXD022198
# License       : Creative Commons Public Domain (CC0), as stated by the PRIDE
#                 project records (see PROVENANCE.md).
# Credentials   : none. The PRIDE Archive is open and unauthenticated. This
#                 script reads no credential environment variables.
# Retrieval     : HTTPS from ftp.pride.ebi.ac.uk. Aspera endpoints are also
#                 published upstream but are not used here.
#
# Download size : default / supplementary   7 files    ~552 MiB
#                 raw                     194 files  ~583.9 GiB
#                   PXD022216  50 x .d.zip (Bruker timsTOF)  ~218.1 GiB
#                   PXD022198 135 x .raw   (Thermo Lumos)    ~340.8 GiB
#                   PXD022216   1 x .sne   (Spectronaut)      ~24.2 GiB
#                   PXD022216   1 x .tsv   (spectral library) ~295.6 MiB
#                 The archive sustains roughly 1.8 MB/s, so `raw` is a
#                 multi-day transfer. Plan accordingly.
#
# Integrity model:
#   Every row in MANIFEST.tsv is Tier A: PRIDE publishes a per-file SHA-1,
#   which is the download-time gate. A mismatch rejects the file.
#   bytes / sha256 / pinned_date are local observations that move as a unit:
#   all three the literal PENDING before the file is retrieved, all three
#   populated after it passes its tier check. This script writes them together,
#   through a temp file and an atomic mv, and only ever turns PENDING into an
#   observed value unless --force says the file was genuinely re-downloaded.
#   It never writes a computed hash into an upstream column, and it never
#   touches git.
#   Upstream byte counts are deliberately absent from the manifest, because
#   `bytes` is a local observation. They live in the saved API artifacts under
#   provenance/upstream/.
#
# Known upstream defect (see PROVENANCE.md):
#   PXD022198/20210107_003_S281243_CLL_CD19selected_Pool6.raw is served by the
#   archive at 4096 bytes while its PRIDE record states 661866438 bytes. Its
#   Tier A check is expected to fail. That failure is correct behaviour.
#
# Source stability: versioned. PRIDE/ProteomeXchange revise deposit metadata
# (both accessions were revised 2024-10-22) but the data files are archival.
# A checksum mismatch is therefore a hard failure, not a warning.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MANIFEST="$SCRIPT_DIR/MANIFEST.tsv"
ROOT="$SCRIPT_DIR"

EXPECTED_HEADER='#path	tier	depth	bytes	sha256	pinned_date	up_algo	up_hash	up_hash_src	up_hash_copy	up_fetched	url'
PENDING='PENDING'
TIER_C_SENTINEL='TIER_C_NO_UPSTREAM_HASH'
TIER_B_SENTINEL='TIER_B_SIZE_ONLY'

DEPTHS=('default' 'supplementary' 'raw')
DEPTH='default'
DEPTH_SEEN=0

do_help=0
do_list_flags=0
do_dry_run=0
do_verify_only=0
do_force=0
do_refresh=0
do_force_pin=0
do_emit_sums=0

TMPFILE=''
cleanup() { [[ -n "$TMPFILE" && -e "$TMPFILE" ]] && rm -f "$TMPFILE"; return 0; }
trap cleanup EXIT

log()  { printf '%s  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"; }
warn() { printf '%s  WARN  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }
die()  { local code="$1"; shift; printf 'ERROR: %s\n' "$*" >&2; exit "$code"; }

usage() {
  cat <<'USAGE'
DOWNLOAD.sh — retrieve and verify PRIDE deposits PXD022216 and PXD022198.

Usage: DOWNLOAD.sh [DEPTH] [options]

DEPTH (optional positional, at most one, default `default`; cumulative):
  default        core processed files: the Spectronaut precursor and protein
                 reports, the three per-batch protein-quantification reports,
                 and both annotation files.  7 files, about 552 MiB.
  supplementary  default plus supplementary and secondary files.  Neither
                 deposit contains any, so this resolves to the same 7 files.
  raw            supplementary plus raw instrument files and bulk inputs: the
                 185 raw MS acquisitions, the exported spectral library and the
                 Spectronaut .sne session archive.  194 files, about 583.9 GiB.

Depth selects which manifest rows every mode acts on. Rows outside it are
reported as out-of-scope, never as missing.

Options:
  --help                print this message and exit 0
  --list-flags          print flag<TAB>arity pairs and exit 0
  --dry-run             resolve and report every planned action, write nothing
  --verify-only         check local files against the manifest; no network, no writes
  --force               re-download even when the checksum matches
  --refresh-manifest    re-fetch upstream checksums and propose a manifest update
  --force-pin           permit --refresh-manifest to alter an existing local pin
  --emit-sha256sums     write a derived SHA256SUMS from the manifest
  --manifest PATH       manifest location (default: alongside this script)
  --root PATH           destination root for the layout (default: alongside this script)

--verify-only statuses:
  OK                   present, pinned, every stored value matches
  MISMATCH             present, pinned, a stored value differs        (exit 1)
  MISSING              absent but pinned — it was here once           (exit 1)
  UNPINNED             present but PENDING — bytes the manifest never recorded (exit 1)
  NOT_YET_DOWNLOADED   absent and PENDING — manifest and disk agree   (exit 0)

Exit codes:
  0 success
  1 verification failure (checksum mismatch, missing or unpinned file)
  2 usage error, including a depth that selects no manifest rows
  3 manifest structural error
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
    --refresh-manifest novalue \
    --force-pin novalue \
    --emit-sha256sums novalue \
    --manifest value \
    --root value
}

# ------------------------------------------------------------ argument parse ---
# Parsing and flag validation precede the manifest gate, so a usage error exits
# 2 even when the manifest is also broken. The one exception is the zero-rows
# check, which by definition needs a parsed manifest.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)             do_help=1 ;;
    --list-flags)       do_list_flags=1 ;;
    --dry-run)          do_dry_run=1 ;;
    --verify-only)      do_verify_only=1 ;;
    --force)            do_force=1 ;;
    --refresh-manifest) do_refresh=1 ;;
    --force-pin)        do_force_pin=1 ;;
    --emit-sha256sums)  do_emit_sums=1 ;;
    --manifest)
      [[ $# -ge 2 ]] || die 2 "--manifest requires a PATH argument"
      MANIFEST="$2"; shift ;;
    --root)
      [[ $# -ge 2 ]] || die 2 "--root requires a PATH argument"
      ROOT="$2"; shift ;;
    -*) die 2 "unknown flag: $1 (try --help)" ;;
    *)
      [[ $DEPTH_SEEN -eq 0 ]] || die 2 "DEPTH may be given at most once (already '$DEPTH', then '$1')"
      case "$1" in
        default|supplementary|raw) DEPTH="$1"; DEPTH_SEEN=1 ;;
        *) die 2 "unknown DEPTH '$1'; expected one of: ${DEPTHS[*]}" ;;
      esac ;;
  esac
  shift
done

if [[ $do_help -eq 1 ]]; then usage; exit 0; fi
if [[ $do_list_flags -eq 1 ]]; then list_flags; exit 0; fi

# ------------------------------------------------------- combination checks ---
if [[ $do_force_pin -eq 1 && $do_refresh -eq 0 ]]; then
  die 2 "--force-pin is only meaningful with --refresh-manifest"
fi
if [[ $do_dry_run -eq 1 && $do_force -eq 1 ]]; then
  die 2 "--dry-run and --force are mutually exclusive"
fi
if [[ $do_verify_only -eq 1 ]]; then
  if [[ $do_force -eq 1 || $do_refresh -eq 1 || $do_emit_sums -eq 1 ]]; then
    die 2 "--verify-only cannot be combined with --force, --refresh-manifest or --emit-sha256sums"
  fi
fi

# ------------------------------------------------------------ tool presence ---
need_tools=(awk date sha1sum sha256sum)
if [[ $do_verify_only -eq 0 ]]; then
  need_tools+=(curl mktemp)
fi
for t in "${need_tools[@]}"; do
  command -v "$t" >/dev/null 2>&1 || die 4 "required tool not found: $t (install it and retry)"
done

# --------------------------------------------------------------- hex helpers ---
hexlen_for_algo() {
  case "$1" in
    md5)    printf '32' ;;
    sha1)   printf '40' ;;
    sha256) printf '64' ;;
    *)      printf '0' ;;
  esac
}

is_hex_of_len() { [[ "$1" =~ ^[0-9a-f]+$ ]] && [[ ${#1} -eq $2 ]]; }

hash_with_algo() { # <algo> <file>
  case "$1" in
    md5)    md5sum    -- "$2" | awk '{print $1}' ;;
    sha1)   sha1sum   -- "$2" | awk '{print $1}' ;;
    sha256) sha256sum -- "$2" | awk '{print $1}' ;;
    *)      return 1 ;;
  esac
}

path_is_safe() { # <relative path>
  local p="$1" c
  [[ -n "$p" ]] || return 1
  [[ "$p" != /* ]] || return 1
  local -a parts
  IFS='/' read -r -a parts <<<"$p"
  for c in "${parts[@]}"; do
    [[ "$c" == '..' || "$c" == '.' || -z "$c" ]] && return 1
  done
  return 0
}

depth_rank() {
  case "$1" in
    default)       printf '0' ;;
    supplementary) printf '1' ;;
    raw)           printf '2' ;;
    *)             printf '9' ;;
  esac
}

# ------------------------------------------------------------- manifest gate ---
M_PATH=(); M_TIER=(); M_DEPTH=(); M_BYTES=(); M_SHA=(); M_PDATE=()
M_UALGO=(); M_UHASH=(); M_USRC=(); M_UCOPY=(); M_UFETCH=(); M_URL=()
IN_SCOPE=0
DEPTH_TALLY=''

load_manifest() {
  [[ -e "$MANIFEST" ]] || die 3 "manifest not found: $MANIFEST"
  [[ -f "$MANIFEST" && -r "$MANIFEST" ]] || die 3 "manifest is not a readable file: $MANIFEST"
  [[ -s "$MANIFEST" ]] || die 3 "manifest is empty: $MANIFEST"

  local first
  IFS= read -r first < "$MANIFEST" || die 3 "manifest has no header line: $MANIFEST"
  first="${first%$'\r'}"
  [[ "$first" == "$EXPECTED_HEADER" ]] || \
    die 3 "manifest header does not match the expected column list (line 1 of $MANIFEST)"

  local lineno=1 n=0
  local path tier depth bytes sha pdate ualgo uhash usrc ucopy ufetch url extra
  local -A seen=()
  local -A dcount=()

  while IFS=$'\t' read -r path tier depth bytes sha pdate ualgo uhash usrc ucopy ufetch url extra || [[ -n "${path:-}" ]]; do
    lineno=$((lineno + 1))
    [[ -z "${path:-}" ]] && continue
    [[ "$path" == \#* ]] && continue

    [[ -z "${extra:-}" ]] || die 3 "line $lineno: too many fields (expected 12)"
    for f in "$tier" "$depth" "$bytes" "$sha" "$pdate" "$ualgo" "$uhash" "$usrc" "$ucopy" "$ufetch" "$url"; do
      [[ -n "${f:-}" ]] || die 3 "line $lineno: wrong field count or empty field (expected 12 non-empty fields)"
    done

    case "$tier" in A|B|C) ;; *) die 3 "line $lineno: tier must be A, B or C, got '$tier'" ;; esac
    case "$depth" in default|supplementary|raw) ;; *) die 3 "line $lineno: depth must be default, supplementary or raw, got '$depth'" ;; esac

    # bytes / sha256 / pinned_date form one local-observation triple: all three
    # PENDING, or all three populated. A half-filled triple claims an
    # observation without the evidence that produced it.
    local npend=0
    [[ "$bytes" == "$PENDING" ]] && npend=$((npend + 1))
    [[ "$sha"   == "$PENDING" ]] && npend=$((npend + 1))
    [[ "$pdate" == "$PENDING" ]] && npend=$((npend + 1))
    if [[ $npend -eq 3 ]]; then
      :
    elif [[ $npend -ne 0 ]]; then
      die 3 "line $lineno: bytes/sha256/pinned_date must be all $PENDING or all populated"
    else
      [[ "$bytes" =~ ^[0-9]+$ ]] || die 3 "line $lineno: bytes is not a non-negative integer: '$bytes'"
      is_hex_of_len "$sha" 64 || die 3 "line $lineno: sha256 must be 64 lowercase hex digits or $PENDING"
      [[ "$pdate" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die 3 "line $lineno: pinned_date must be YYYY-MM-DD or $PENDING"
    fi

    case "$tier" in
      A)
        local want; want="$(hexlen_for_algo "$ualgo")"
        [[ "$want" != '0' ]] || die 3 "line $lineno: tier A up_algo must be md5, sha1 or sha256, got '$ualgo'"
        [[ "$uhash" != "$PENDING" ]] || die 3 "line $lineno: tier A up_hash must never be $PENDING"
        is_hex_of_len "$uhash" "$want" || die 3 "line $lineno: tier A up_hash is not $want lowercase hex digits for algo $ualgo"
        [[ "$uhash" != "$sha" ]] || die 3 "line $lineno: up_hash equals the local sha256 pin — a computed hash must not stand in as upstream authority"
        [[ "$usrc" == https://* ]] || die 3 "line $lineno: tier A up_hash_src must be an https URL"
        [[ "$ucopy" != '-' ]] || die 3 "line $lineno: tier A up_hash_copy must name a saved artifact"
        [[ "$ufetch" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die 3 "line $lineno: tier A up_fetched must be YYYY-MM-DD"
        ;;
      B)
        [[ "$ualgo" == "$TIER_B_SENTINEL" ]] || die 3 "line $lineno: tier B up_algo must be $TIER_B_SENTINEL"
        [[ "$uhash" == '-' ]] || die 3 "line $lineno: tier B up_hash must be '-'"
        ;;
      C)
        [[ "$ualgo" == "$TIER_C_SENTINEL" ]] || die 3 "line $lineno: tier C up_algo must be $TIER_C_SENTINEL"
        for f in "$uhash" "$usrc" "$ucopy" "$ufetch"; do
          [[ "$f" == '-' ]] || die 3 "line $lineno: tier C upstream columns must all be '-'"
        done
        ;;
    esac

    path_is_safe "$path" || die 3 "line $lineno: unsafe path '$path' (absolute, empty, or containing . / ..)"
    [[ -z "${seen[$path]:-}" ]] || die 3 "line $lineno: duplicate path '$path'"
    seen["$path"]=1
    [[ "$url" == https://* ]] || die 3 "line $lineno: url must be https, got '$url'"

    M_PATH+=("$path");   M_TIER+=("$tier");   M_DEPTH+=("$depth")
    M_BYTES+=("$bytes"); M_SHA+=("$sha");     M_PDATE+=("$pdate")
    M_UALGO+=("$ualgo"); M_UHASH+=("$uhash"); M_USRC+=("$usrc")
    M_UCOPY+=("$ucopy"); M_UFETCH+=("$ufetch"); M_URL+=("$url")
    dcount["$depth"]=$(( ${dcount[$depth]:-0} + 1 ))
    n=$((n + 1))
  done < <(tail -n +2 "$MANIFEST")

  [[ $n -gt 0 ]] || die 3 "manifest parsed zero records: $MANIFEST"

  local d
  for d in "${DEPTHS[@]}"; do
    DEPTH_TALLY+="$d=${dcount[$d]:-0} "
  done

  local i
  for ((i = 0; i < n; i++)); do
    [[ "$(depth_rank "${M_DEPTH[i]}")" -le "$(depth_rank "$DEPTH")" ]] && IN_SCOPE=$((IN_SCOPE + 1))
  done
  log "depth=$DEPTH  in-scope=$IN_SCOPE of $n rows  (rows per depth: ${DEPTH_TALLY% })  manifest=$MANIFEST"
  [[ $IN_SCOPE -gt 0 ]] || \
    die 2 "depth '$DEPTH' selects none of the $n manifest rows (rows per depth: ${DEPTH_TALLY% }) — nothing to do"
}

selected() { # <index>
  [[ "$(depth_rank "${M_DEPTH[$1]}")" -le "$(depth_rank "$DEPTH")" ]]
}

# Write one row's local-observation triple into MANIFEST.tsv. This is the only
# manifest mutation permitted outside --refresh-manifest, it touches exactly
# fields 4-6, and it never touches an upstream column.
write_pin() { # <path> <bytes> <sha256> <date>
  local tmp was_ro=0
  tmp="$(mktemp "$(dirname "$MANIFEST")/.MANIFEST.XXXXXXXX")"
  chmod 0644 "$tmp"
  awk -F'\t' -v OFS='\t' -v p="$1" -v b="$2" -v h="$3" -v d="$4" '
    NR == 1 { print; next }
    $1 == p { $4 = b; $5 = h; $6 = d }
    { print }
  ' "$MANIFEST" > "$tmp"
  [[ -w "$MANIFEST" ]] || was_ro=1
  mv -f "$tmp" "$MANIFEST"
  [[ $was_ro -eq 1 ]] && chmod a-w "$MANIFEST"
  return 0
}

# ------------------------------------------------------------- --verify-only ---
verify_only() {
  local ok=0 mismatch=0 missing=0 unpinned=0 notyet=0 oos=0 i
  local total=${#M_PATH[@]}
  log "verifying depth $DEPTH under $ROOT (no network, no writes)"
  for ((i = 0; i < total; i++)); do
    local p="${M_PATH[i]}" f="$ROOT/${M_PATH[i]}"
    if ! selected "$i"; then
      printf 'OUT-OF-SCOPE        depth=%-13s %s\n' "${M_DEPTH[i]}" "$p"
      oos=$((oos + 1)); continue
    fi
    local pend=0
    [[ "${M_SHA[i]}" == "$PENDING" ]] && pend=1
    if [[ ! -f "$f" ]]; then
      if [[ $pend -eq 1 ]]; then
        printf 'NOT_YET_DOWNLOADED  tier=%s  %s\n' "${M_TIER[i]}" "$p"
        notyet=$((notyet + 1))
      else
        printf 'MISSING             tier=%s  %s  [pinned %s but absent]\n' "${M_TIER[i]}" "$p" "${M_PDATE[i]}"
        missing=$((missing + 1))
      fi
      continue
    fi
    if [[ $pend -eq 1 ]]; then
      printf 'UNPINNED            tier=%s  %s  [on disk but the manifest records no observation]\n' "${M_TIER[i]}" "$p"
      unpinned=$((unpinned + 1)); continue
    fi
    local bad=0 notes=()
    if [[ "${M_TIER[i]}" == 'A' ]]; then
      local got; got="$(hash_with_algo "${M_UALGO[i]}" "$f")" || { bad=1; notes+=("cannot compute ${M_UALGO[i]}"); got=''; }
      if [[ -n "$got" ]]; then
        if [[ "$got" == "${M_UHASH[i]}" ]]; then notes+=("publisher ${M_UALGO[i]} matches")
        else bad=1; notes+=("publisher ${M_UALGO[i]} MISMATCH"); fi
      fi
    fi
    local size; size="$(wc -c < "$f" | tr -d ' ')"
    [[ "$size" == "${M_BYTES[i]}" ]] || { bad=1; notes+=("size $size != pinned ${M_BYTES[i]}"); }
    local gs; gs="$(sha256sum -- "$f" | awk '{print $1}')"
    if [[ "$gs" == "${M_SHA[i]}" ]]; then notes+=("sha256 pin matches — unchanged since ${M_PDATE[i]}")
    else bad=1; notes+=("sha256 pin MISMATCH"); fi
    if [[ $bad -eq 0 ]]; then
      printf 'OK                  tier=%s  %s  [%s]\n' "${M_TIER[i]}" "$p" "$(IFS='|'; echo "${notes[*]}")"
      ok=$((ok + 1))
    else
      printf 'MISMATCH            tier=%s  %s  [%s]\n' "${M_TIER[i]}" "$p" "$(IFS='|'; echo "${notes[*]}")"
      mismatch=$((mismatch + 1))
    fi
  done
  printf '\nverify summary (depth %s): %d OK, %d MISMATCH, %d MISSING, %d UNPINNED, %d NOT_YET_DOWNLOADED, %d out of scope, of %d rows\n' \
    "$DEPTH" "$ok" "$mismatch" "$missing" "$unpinned" "$notyet" "$oos" "$total"
  printf 'note: NOT_YET_DOWNLOADED is not a failure — the manifest says the file is unfetched and the disk agrees.\n'
  printf 'note: this detects local drift, not upstream change. Use --dry-run or --refresh-manifest for that.\n'
  [[ $mismatch -eq 0 && $missing -eq 0 && $unpinned -eq 0 ]]
}

# ---------------------------------------------------------- --emit-sha256sums ---
emit_sha256sums() {
  local out="$ROOT/SHA256SUMS" i wrote=0 skipped=0 oos=0
  mkdir -p "$ROOT"
  : > "$out"
  for ((i = 0; i < ${#M_PATH[@]}; i++)); do
    selected "$i" || { oos=$((oos + 1)); continue; }
    if [[ "${M_SHA[i]}" == "$PENDING" ]]; then skipped=$((skipped + 1)); continue; fi
    printf '%s  %s\n' "${M_SHA[i]}" "${M_PATH[i]}" >> "$out"
    wrote=$((wrote + 1))
  done
  log "wrote $out ($wrote entries; $skipped in-scope rows still $PENDING and omitted; $oos out of scope)"
  log "derived from MANIFEST.tsv — never hand-edit, and it is git-ignored; verify with: (cd '$ROOT' && sha256sum -c SHA256SUMS)"
}

# ----------------------------------------------------------------- --dry-run ---
dry_run() {
  local i n=0 present=0 unreachable=0 oos=0
  log "dry run at depth $DEPTH: nothing will be written"
  for ((i = 0; i < ${#M_PATH[@]}; i++)); do
    if ! selected "$i"; then
      printf 'OUT-OF-SCOPE   depth=%-13s %s\n' "${M_DEPTH[i]}" "${M_PATH[i]}"
      oos=$((oos + 1)); continue
    fi
    n=$((n + 1))
    local state='WOULD DOWNLOAD'
    [[ -f "$ROOT/${M_PATH[i]}" ]] && { state='PRESENT'; present=$((present + 1)); }
    local code
    code="$(curl -sIL -m 60 --retry 2 --retry-delay 3 --proto '=https' --tlsv1.2 \
              -o /dev/null -w '%{http_code}' -- "${M_URL[i]}" 2>/dev/null || echo 000)"
    [[ "$code" == '200' ]] || unreachable=$((unreachable + 1))
    printf '%-14s HTTP %s  tier=%s depth=%-13s pin=%s  %s\n' \
      "$state" "$code" "${M_TIER[i]}" "${M_DEPTH[i]}" \
      "$( [[ "${M_SHA[i]}" == "$PENDING" ]] && printf 'PENDING' || printf 'set' )" \
      "${M_PATH[i]}"
  done
  printf '\ndry-run summary (depth %s): %d selected, %d already present, %d out of scope, %d URLs not answering 200\n' \
    "$DEPTH" "$n" "$present" "$oos" "$unreachable"
  [[ $unreachable -eq 0 ]] || warn "$unreachable of $n selected URLs did not answer HTTP 200"
  return 0
}

# ------------------------------------------------------------------ download ---
download_all() {
  local i downloaded=0 pinned_existing=0 skipped_ok=0 failed=0 oos=0
  log "downloading depth $DEPTH into $ROOT"
  for ((i = 0; i < ${#M_PATH[@]}; i++)); do
    if ! selected "$i"; then oos=$((oos + 1)); continue; fi
    local rel="${M_PATH[i]}" dest="$ROOT/${M_PATH[i]}" dir
    dir="$(dirname "$dest")"
    mkdir -p "$dir"
    local today; today="$(date -u '+%Y-%m-%d')"

    if [[ -f "$dest" && $do_force -eq 0 ]]; then
      local got; got="$(hash_with_algo "${M_UALGO[i]}" "$dest")" || got=''
      if [[ -n "$got" && "$got" == "${M_UHASH[i]}" ]]; then
        if [[ "${M_SHA[i]}" == "$PENDING" ]]; then
          # Bytes already on disk that the manifest has never recorded. The
          # tier gate has just passed against the publisher hash, so the
          # observation is warranted: pin it rather than leave an UNPINNED row.
          local size pin
          size="$(wc -c < "$dest" | tr -d ' ')"
          pin="$(sha256sum -- "$dest" | awk '{print $1}')"
          write_pin "$rel" "$size" "$pin" "$today"
          M_BYTES[i]="$size"; M_SHA[i]="$pin"; M_PDATE[i]="$today"
          chmod a-w "$dest"
          log "PIN existing file (publisher ${M_UALGO[i]} matches, no transfer): $rel"
          pinned_existing=$((pinned_existing + 1)); continue
        fi
        log "SKIP complete (publisher ${M_UALGO[i]} matches, pin set): $rel"
        skipped_ok=$((skipped_ok + 1)); continue
      fi
      warn "present but does not match the publisher ${M_UALGO[i]}: $rel — re-downloading"
    fi

    TMPFILE="$(mktemp "$dir/.dl.XXXXXXXX")"
    log "GET $rel"
    if ! curl -fL --retry 3 --retry-delay 5 --proto '=https' --tlsv1.2 \
              -o "$TMPFILE" -- "${M_URL[i]}"; then
      rm -f "$TMPFILE"; TMPFILE=''
      warn "retrieval failed: $rel"
      failed=$((failed + 1)); continue
    fi

    local gate_ok=1
    case "${M_TIER[i]}" in
      A)
        local got; got="$(hash_with_algo "${M_UALGO[i]}" "$TMPFILE")" || got=''
        if [[ -z "$got" ]]; then
          warn "cannot compute ${M_UALGO[i]} for $rel"; gate_ok=0
        elif [[ "$got" != "${M_UHASH[i]}" ]]; then
          warn "TIER A MISMATCH $rel: publisher ${M_UALGO[i]}=${M_UHASH[i]} got=$got"; gate_ok=0
        else
          log "tier A OK: publisher ${M_UALGO[i]} matches for $rel"
        fi
        ;;
      B)
        if [[ "${M_BYTES[i]}" == "$PENDING" ]]; then
          warn "tier B row with no pinned size to compare: $rel"; gate_ok=0
        else
          local size; size="$(wc -c < "$TMPFILE" | tr -d ' ')"
          [[ "$size" == "${M_BYTES[i]}" ]] || { warn "TIER B SIZE MISMATCH $rel: expected ${M_BYTES[i]} got $size"; gate_ok=0; }
        fi
        ;;
      C)
        if [[ "${M_SHA[i]}" == "$PENDING" ]]; then
          log "tier C first use (trust-on-first-use): pinning $rel"
        else
          local gs; gs="$(sha256sum -- "$TMPFILE" | awk '{print $1}')"
          [[ "$gs" == "${M_SHA[i]}" ]] || { warn "TIER C PIN MISMATCH $rel"; gate_ok=0; }
        fi
        ;;
    esac

    if [[ $gate_ok -eq 0 ]]; then
      rm -f "$TMPFILE"; TMPFILE=''
      failed=$((failed + 1)); continue
    fi

    # Only after the tier gate passes: compute the local observation triple.
    local pin size
    pin="$(sha256sum -- "$TMPFILE" | awk '{print $1}')"
    size="$(wc -c < "$TMPFILE" | tr -d ' ')"
    chmod 0644 "$TMPFILE"
    mv -f "$TMPFILE" "$dest"
    TMPFILE=''
    chmod a-w "$dest"
    if [[ "${M_SHA[i]}" == "$PENDING" || $do_force -eq 1 ]]; then
      write_pin "$rel" "$size" "$pin" "$today"
      M_BYTES[i]="$size"; M_SHA[i]="$pin"; M_PDATE[i]="$today"
    elif [[ "$pin" != "${M_SHA[i]}" ]]; then
      warn "installed $rel passed its tier gate but its sha256 differs from the manifest pin; --force is required to move a set pin"
    fi
    log "OK $rel -> $dest (mode 444, pin written)"
    downloaded=$((downloaded + 1))
  done

  printf '\ndownload summary (depth %s): %d downloaded, %d already-present files pinned, %d already complete, %d failed, %d out of scope\n' \
    "$DEPTH" "$downloaded" "$pinned_existing" "$skipped_ok" "$failed" "$oos"
  if [[ $((downloaded + pinned_existing)) -gt 0 ]]; then
    printf 'MANIFEST.tsv gained %d pin(s). Commit it on its own:\n' "$((downloaded + pinned_existing))"
    printf "  git add MANIFEST.tsv && git commit -m 'data(cll-proteomics): pin %d files at depth %s'\n" \
      "$((downloaded + pinned_existing))" "$DEPTH"
  fi
  [[ $failed -eq 0 ]] || return 4
  return 0
}

# -------------------------------------------------------- --refresh-manifest ---
refresh_manifest() {
  local i
  log "re-fetching the upstream sources of the in-scope rows at depth $DEPTH"
  local -A srcs=()
  for ((i = 0; i < ${#M_PATH[@]}; i++)); do
    selected "$i" || continue
    [[ "${M_USRC[i]}" == '-' ]] && continue
    srcs["${M_USRC[i]}"]="${M_UCOPY[i]}"
  done
  local url copy out
  for url in "${!srcs[@]}"; do
    copy="${srcs[$url]}"; out="$ROOT/$copy"
    mkdir -p "$(dirname "$out")"
    log "GET $url -> $copy"
    curl -fL --retry 3 --retry-delay 5 --proto '=https' --tlsv1.2 -o "$out.new" -- "$url" \
      || die 4 "could not re-fetch $url"
    chmod 0644 "$out.new"
    mv -f "$out.new" "$out"
    chmod a-w "$out"
  done

  local cand; cand="$(mktemp "$(dirname "$MANIFEST")/.MANIFEST.XXXXXXXX")"
  # mktemp creates 0600; the manifest must stay world-readable like the data.
  chmod 0644 "$cand"
  printf '%s\n' "$EXPECTED_HEADER" > "$cand"
  for ((i = 0; i < ${#M_PATH[@]}; i++)); do
    local uhash="${M_UHASH[i]}" ufetch="${M_UFETCH[i]}"
    if selected "$i" && [[ "${M_UCOPY[i]}" != '-' && -f "$ROOT/${M_UCOPY[i]}" ]]; then
      ufetch="$(date -u '+%Y-%m-%d')"
      local base fresh
      base="$(basename "${M_PATH[i]}")"
      fresh="$(python3 - "$ROOT/${M_UCOPY[i]}" "$base" <<'PY' 2>/dev/null || true
import json,sys
try:
    recs=json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
for r in recs if isinstance(recs,list) else []:
    if r.get("fileName")==sys.argv[2]:
        print(r.get("checksum","")); break
PY
)"
      if [[ -n "$fresh" && "$fresh" != "$uhash" ]]; then
        if [[ $do_force_pin -eq 1 ]]; then
          warn "upstream ${M_UALGO[i]} changed for ${M_PATH[i]} — taking the new value"
          uhash="$fresh"
        else
          warn "upstream ${M_UALGO[i]} changed for ${M_PATH[i]} — keeping the old value; rerun with --force-pin to accept it"
        fi
      fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "${M_PATH[i]}" "${M_TIER[i]}" "${M_DEPTH[i]}" "${M_BYTES[i]}" "${M_SHA[i]}" "${M_PDATE[i]}" \
      "${M_UALGO[i]}" "$uhash" "${M_USRC[i]}" "${M_UCOPY[i]}" "$ufetch" "${M_URL[i]}" >> "$cand"
  done

  log "validating the candidate manifest structurally"
  local st=0
  bash "${BASH_SOURCE[0]}" raw --verify-only --manifest "$cand" --root "$ROOT" >/dev/null 2>&1 || st=$?
  if [[ $st -eq 2 || $st -eq 3 ]]; then
    rm -f "$cand"; die 3 "candidate manifest failed structural validation (exit $st)"
  fi

  printf '\n--- field-level diff (current -> candidate) ---\n'
  if diff -u "$MANIFEST" "$cand" >/dev/null 2>&1; then
    printf 'no changes\n'; rm -f "$cand"; return 0
  fi
  diff -u "$MANIFEST" "$cand" || true
  printf '\nInstall this candidate over %s? [type yes] ' "$MANIFEST"
  local ans=''
  read -r ans || true
  if [[ "$ans" == 'yes' ]]; then
    local was_ro=0
    [[ -w "$MANIFEST" ]] || was_ro=1
    mv -f "$cand" "$MANIFEST"
    [[ $was_ro -eq 1 ]] && chmod a-w "$MANIFEST"
    log "manifest updated — add a dated row to the PROVENANCE.md changelog, then commit both:"
    printf "  git add MANIFEST.tsv PROVENANCE.md && git commit -m 'data(cll-proteomics): refresh upstream hashes'\n"
  else
    rm -f "$cand"
    log "candidate discarded; manifest unchanged"
  fi
  return 0
}

# ---------------------------------------------------------------------- main ---
load_manifest

if [[ $do_verify_only -eq 1 ]]; then
  st=0; verify_only || st=1
  exit "$st"
fi

if [[ $do_emit_sums -eq 1 ]]; then
  emit_sha256sums
  [[ $do_dry_run -eq 1 || $do_refresh -eq 1 ]] || exit 0
fi

if [[ $do_refresh -eq 1 ]]; then
  refresh_manifest
  exit 0
fi

if [[ $do_dry_run -eq 1 ]]; then
  dry_run
  exit 0
fi

st=0; download_all || st=$?
exit "$st"
