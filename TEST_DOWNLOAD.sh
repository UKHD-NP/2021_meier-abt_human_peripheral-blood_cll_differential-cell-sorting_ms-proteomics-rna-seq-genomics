#!/usr/bin/env bash
# TEST_DOWNLOAD.sh — establish that DOWNLOAD.sh and the documentation bundle in
# this directory are correct and safe, without re-downloading the bulk data and
# without writing to the real data directories.
#
# Run:
#   ./TEST_DOWNLOAD.sh                        offline checks only (default)
#   DATASET_TEST_NETWORK=1 ./TEST_DOWNLOAD.sh offline checks + network checks
#
# The network section is OFF by default. It re-fetches the upstream checksum
# artifacts, HEADs all 194 deposit URLs, and downloads the single smallest
# `default`-depth file (5219 bytes) into a temporary sandbox. Nothing it does
# writes into PXD022216/ or PXD022198/, and nothing it does touches the real
# MANIFEST.tsv.
#
# What each check proves
# ---------------------
# static            DOWNLOAD.sh parses; shellcheck finds no defect (SKIP if absent).
# safety greps      No TLS bypass, no eval, no pipe-to-interpreter, no embedded
#                   credential, no rm -rf on an unquoted path, no leftover
#                   --include-optional (the contract has no such flag).
# no-hashes         No 32/40/64-hex literal in DOWNLOAD.sh: hashes live only in
#                   MANIFEST.tsv, so a hash change is always a data-file diff.
# cli conformance   Delegated to the skill's check_download_api.sh so a contract
#                   change propagates here without editing this file. That
#                   script owns the flag set, the DEPTH positional, the exit
#                   codes, and the generic manifest-gate rejection fixtures.
# template          No unfilled {{SLOT}} survives; MANIFEST header is
#                   byte-identical to the canonical 12-column header.
# manifest struct   Field count, sort order, uniqueness, hex well-formedness,
#                   path safety, tier rules — checked independently of
#                   DOWNLOAD.sh's own gate.
# depth column      Every depth is default|supplementary|raw; at least one row
#                   is at default, so the no-argument invocation is never a
#                   usage error; and README's depth table agrees with the
#                   manifest on per-depth file counts.
# pin state         Every row is all-PENDING or all-populated; no file on disk
#                   has a PENDING row (that is UNPINNED); no absent file has a
#                   populated one (that is MISSING). Catching these offline is
#                   cheaper than catching them mid-analysis.
# tier integrity    No Tier A row with a placeholder or PENDING upstream hash,
#                   no Tier C row carrying an upstream URL, no row reusing its
#                   sha256 as its up_hash.
# evidence          Every Tier A up_hash appears verbatim in the saved artifact
#                   named by up_hash_copy. This is what makes the manifest's
#                   upstream column evidence rather than assertion, and it works
#                   offline and survives the publisher taking the API down.
# fixtures          Dataset-specific malformed manifests DOWNLOAD.sh must reject
#                   with exit 3, beyond the generic ones the checker supplies.
# cross-document    Every MANIFEST path is covered by exactly one pattern in the
#                   README tree and one in the PROVENANCE file-description
#                   table, and every pattern covers at least one path. This
#                   proves the three documents we wrote agree with each other.
#                   It does NOT prove any of them is true — the evidence and
#                   authority checks are what establish that.
# depth behaviour   --verify-only at each depth exits 0 or 1, never 2 or 3, and
#                   reports out-of-depth rows as out-of-scope, never as missing.
# statistics        Every file named in README's statistics table exists in
#                   MANIFEST.tsv and has a recorded invocation. The numbers are
#                   NOT recomputed here — that is matrix_stats.py's job, run
#                   deliberately, because recomputing turns a documentation
#                   check into a minutes-long job on a 456 MB matrix.
# anti-laundering   No code path writes a computed hash into an upstream column;
#                   MANIFEST.tsv is written only by write_pin() and
#                   refresh_manifest(); and write_pin() assigns only fields 4-6,
#                   the local-observation triple.
# version control   MANIFEST.tsv is tracked, committed and clean, and no data
#                   file listed in it appears in git ls-files.
# verify real dir   --verify-only against the real directory, at every depth.
#                   Reads, never writes.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DL="$SCRIPT_DIR/DOWNLOAD.sh"
MANIFEST="$SCRIPT_DIR/MANIFEST.tsv"
README="$SCRIPT_DIR/README.md"
PROV="$SCRIPT_DIR/PROVENANCE.md"
SKILL="$SCRIPT_DIR/.skills/dataset-documentation"
CANON_HEADER="$SKILL/assets/MANIFEST.header.tsv"
API_CONTRACT="$SKILL/assets/download-api.tsv"
CHECKER="$SKILL/scripts/check_download_api.sh"

PASS=0; FAIL=0; SKIP=0; WARN=0
ok()   { printf 'PASS  %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf 'FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }
skip() { printf 'SKIP  %s\n' "$1"; SKIP=$((SKIP+1)); }
warn() { printf 'WARN  %s\n' "$1"; WARN=$((WARN+1)); }
sect() { printf '\n== %s ==\n' "$1"; }

# ------------------------------------------------------------------- guard ---
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT
case "$SANDBOX" in
  "$SCRIPT_DIR"|"$SCRIPT_DIR"/*)
    printf 'ERROR: sandbox %s is inside the data layout — refusing to run\n' "$SANDBOX" >&2
    exit 1 ;;
esac
ok "sandbox $SANDBOX is outside the data layout"

for f in "$DL" "$MANIFEST" "$README" "$PROV" "$CANON_HEADER" "$API_CONTRACT" "$CHECKER"; do
  [[ -f "$f" ]] || { printf 'ERROR: required file missing: %s\n' "$f" >&2; exit 1; }
done
ok "all bundle files present"
MSUM_BEFORE="$(sha256sum "$MANIFEST" | awk '{print $1}')"

# =============================================================== offline ===
sect "static analysis"
if bash -n "$DL" 2>/dev/null; then ok "bash -n DOWNLOAD.sh"; else bad "bash -n DOWNLOAD.sh"; fi
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -S warning "$DL" >"$SANDBOX/sc.txt" 2>&1; then
    ok "shellcheck clean at severity warning"
  else
    bad "shellcheck reported findings (see below)"; sed 's/^/      /' "$SANDBOX/sc.txt"
  fi
else
  skip "shellcheck not installed — static lint did not run"
fi
if bash -n "$0" 2>/dev/null; then ok "bash -n TEST_DOWNLOAD.sh"; else bad "bash -n TEST_DOWNLOAD.sh"; fi

sect "safety greps"
g() { # <label> <extended regex that must NOT match>
  if grep -Eqn -e "$2" "$DL"; then bad "$1"; grep -Ens -e "$2" "$DL" | sed 's/^/      /'
  else ok "$1"; fi
}
g "no --insecure / -k / --no-check-certificate" '--insecure|--no-check-certificate|[[:space:]]-k[[:space:]]'
g "no eval"                                     '(^|[^[:alnum:]_])eval[[:space:]]'
g "no pipe from curl/wget into an interpreter"   '(curl|wget)[^|]*\|[[:space:]]*(ba)?sh|(curl|wget)[^|]*\|[[:space:]]*python'
g "no rm -rf on an unquoted or bare-variable path" 'rm[[:space:]]+-[rR]f?[fF]?[[:space:]]+\$?[A-Za-z0-9_{]'
g "no embedded credential literal"               '(password|passwd|secret|api_?key|token)[[:space:]]*=[[:space:]]*["'"'"'][^"'"'"']'
g "no --include-optional (not in the contract)"  '\-\-include-optional'
# DOWNLOAD.sh is required to *print* a suggested git command; it must never run
# one. Filter out the printf/echo lines before looking for an invocation.
if grep -vE 'printf|echo' "$DL" | grep -Eq '(^|[;&|]|\$\()[[:space:]]*git[[:space:]]+(add|commit|init|push|tag)'; then
  bad "DOWNLOAD.sh invokes git — committing is the human's decision"
  grep -vE 'printf|echo' "$DL" | grep -En '(^|[;&|]|\$\()[[:space:]]*git[[:space:]]+(add|commit|init|push|tag)' | sed 's/^/      /'
else
  ok "DOWNLOAD.sh never runs git (it only prints the suggested command)"
fi

sect "no-hashes invariant"
if grep -Eq '\b[0-9a-fA-F]{32}\b|\b[0-9a-fA-F]{40}\b|\b[0-9a-fA-F]{64}\b' "$DL"; then
  bad "hash literal present in DOWNLOAD.sh"
else
  ok "no 32/40/64-hex literal anywhere in DOWNLOAD.sh"
fi

sect "CLI conformance (delegated to the skill checker)"
if bash "$CHECKER" "$DL" "$API_CONTRACT" >"$SANDBOX/api.txt" 2>&1; then
  ok "check_download_api.sh exits 0 ($(grep -c '^PASS' "$SANDBOX/api.txt") checks)"
else
  bad "check_download_api.sh failed"; sed 's/^/      /' "$SANDBOX/api.txt"
fi

sect "template conformance"
for f in "$README" "$PROV"; do
  if grep -Fq '{{' "$f"; then bad "$(basename "$f") still contains an unfilled {{SLOT}}"
  else ok "$(basename "$f") has no unfilled {{SLOT}}"; fi
done
if [[ "$(head -n 1 "$MANIFEST")" == "$(head -n 1 "$CANON_HEADER")" ]]; then
  ok "MANIFEST.tsv header is byte-identical to the canonical header"
else
  bad "MANIFEST.tsv header differs from $CANON_HEADER"
fi

sect "manifest structure, tier and pin integrity"
awk -F'\t' -v canon="$(head -n 1 "$CANON_HEADER")" -v root="$SCRIPT_DIR" '
  function exists(p) { return (system("test -f \"" root "/" p "\"") == 0) }
  NR==1 { if ($0 != canon) { print "header mismatch"; e=1 } ; next }
  /^#/  { next }
  NF==0 { next }
  {
    n++
    if (NF != 12) { printf "line %d: %d fields, expected 12\n", NR, NF; e=1 }
    if ($1 <= prev && prev != "") { printf "line %d: not sorted by path (%s after %s)\n", NR, $1, prev; e=1 }
    prev = $1
    if (seen[$1]++) { printf "line %d: duplicate path %s\n", NR, $1; e=1 }
    if ($1 ~ /(^|\/)\.\.(\/|$)/ || $1 ~ /^\//) { printf "line %d: unsafe path %s\n", NR, $1; e=1 }
    if ($2 != "A" && $2 != "B" && $2 != "C") { printf "line %d: bad tier %s\n", NR, $2; e=1 }
    if ($3 != "default" && $3 != "supplementary" && $3 != "raw") { printf "line %d: bad depth %s\n", NR, $3; e=1 }
    depths[$3]++
    for (i = 1; i <= 12; i++) if ($i == "") { printf "line %d: empty field %d\n", NR, i; e=1 }
    p = ($4 == "PENDING") + ($5 == "PENDING") + ($6 == "PENDING")
    if (p != 0 && p != 3) { printf "line %d: half-PENDING local triple\n", NR; e=1 }
    if (p == 0) {
      if ($4 !~ /^[0-9]+$/)       { printf "line %d: bytes not numeric\n", NR; e=1 }
      if ($5 !~ /^[0-9a-f]{64}$/) { printf "line %d: bad sha256\n", NR; e=1 }
      if ($6 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) { printf "line %d: bad pinned_date\n", NR; e=1 }
      pinned++
      if (!exists($1)) { printf "line %d: pinned but absent from disk (MISSING): %s\n", NR, $1; e=1 }
    } else {
      pend++
      if (exists($1)) { printf "line %d: on disk but PENDING (UNPINNED): %s\n", NR, $1; e=1 }
    }
    want = ($7 == "md5") ? 32 : ($7 == "sha1") ? 40 : ($7 == "sha256") ? 64 : 0
    if ($2 == "A") {
      if (want == 0) { printf "line %d: tier A unknown up_algo %s\n", NR, $7; e=1 }
      else if ($8 !~ /^[0-9a-f]+$/ || length($8) != want) { printf "line %d: up_hash wrong length for %s\n", NR, $7; e=1 }
      if ($8 == $5) { printf "line %d: up_hash reuses the local sha256 pin\n", NR; e=1 }
      if ($9 !~ /^https:\/\//) { printf "line %d: up_hash_src is not https\n", NR; e=1 }
      if ($10 == "-") { printf "line %d: tier A without a saved artifact\n", NR; e=1 }
      if ($8 ~ /^(-|TBD|PENDING|UNKNOWN|PLACEHOLDER)/) { printf "line %d: tier A placeholder up_hash\n", NR; e=1 }
      if ($11 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) { printf "line %d: bad up_fetched\n", NR; e=1 }
    }
    if ($2 == "C") {
      if ($7 != "TIER_C_NO_UPSTREAM_HASH") { printf "line %d: tier C up_algo sentinel wrong\n", NR; e=1 }
      for (i = 8; i <= 11; i++) if ($i != "-") { printf "line %d: tier C upstream column %d not \"-\"\n", NR, i; e=1 }
    }
    if ($12 !~ /^https:\/\//) { printf "line %d: url is not https\n", NR; e=1 }
  }
  END {
    if (n == 0) { print "zero records"; e=1 }
    if (depths["default"] == 0) { print "no row at depth default — the no-argument invocation would be a usage error"; e=1 }
    if (e) exit 1
    printf "records=%d pinned=%d pending=%d default=%d supplementary=%d raw=%d\n", \
      n, pinned, pend, depths["default"], depths["supplementary"]+0, depths["raw"]+0
  }
' "$MANIFEST" >"$SANDBOX/mstruct.txt" 2>&1
if [[ $? -eq 0 ]]; then
  ok "manifest structure, tier and pin integrity ($(tail -n 1 "$SANDBOX/mstruct.txt"))"
else
  bad "manifest structure / tier / pin problems"; sed 's/^/      /' "$SANDBOX/mstruct.txt"
fi

sect "README depth table agrees with the manifest"
mism=0
for d in default supplementary raw; do
  mcount=$(awk -F'\t' -v d="$d" 'NR>1 && $3==d {n++} END{print n+0}' "$MANIFEST")
  rcount=$(awk -F'|' -v d="\`$d\`" '$2 ~ d {gsub(/ /,"",$4); print $4; exit}' "$README")
  if [[ -z "$rcount" ]]; then
    bad "README depth table has no row for \`$d\`"; mism=$((mism+1))
  elif [[ "$rcount" != "$mcount" ]]; then
    bad "README depth table says $rcount files at \`$d\`, manifest has $mcount"; mism=$((mism+1))
  fi
done
[[ $mism -eq 0 ]] && ok "README depth table matches the manifest for all three depths"

sect "evidence check (Tier A up_hash present in its saved artifact)"
missing_art=0; missing_val=0; checked=0
while IFS=$'\t' read -r path tier _depth _bytes _sha _pd _ua uhash _us ucopy _uf _url; do
  [[ "$path" == \#* || -z "$path" ]] && continue
  [[ "$tier" == 'A' ]] || continue
  checked=$((checked+1))
  art="$SCRIPT_DIR/$ucopy"
  if [[ ! -f "$art" ]]; then missing_art=$((missing_art+1)); continue; fi
  grep -Fq -- "$uhash" "$art" || { missing_val=$((missing_val+1)); printf '      %s: up_hash not found in %s\n' "$path" "$ucopy"; }
done < <(tail -n +2 "$MANIFEST")
if [[ $missing_art -eq 0 && $missing_val -eq 0 ]]; then
  ok "all $checked Tier A upstream hashes appear verbatim in their saved artifacts"
else
  bad "$missing_art artifacts missing, $missing_val hashes not found in their artifact"
fi

sect "dataset-specific rejection fixtures"
HDR="$(head -n 1 "$CANON_HEADER")"
GOOD_ROW="$(awk -F'\t' 'NR>1 && $4!="PENDING" {print; exit}' "$MANIFEST")"
if [[ -z "$GOOD_ROW" ]]; then
  GOOD_ROW="$(awk -F'\t' 'NR>1 {print; exit}' "$MANIFEST")"
  warn "no pinned row available; fixtures mutate a PENDING row instead"
else
  ok "found a fully-pinned manifest row to mutate"
fi
fixture() { # <label> <row producer>
  local label="$1"; shift
  local m="$SANDBOX/fx.tsv"
  { printf '%s\n' "$HDR"; "$@"; } > "$m"
  mkdir -p "$SANDBOX/fxroot"
  local before after st
  before=$(find "$SANDBOX/fxroot" -type f | wc -l)
  ( cd "$SANDBOX" && bash "$DL" raw --manifest "$m" --root "$SANDBOX/fxroot" >/dev/null 2>&1 ); st=$?
  after=$(find "$SANDBOX/fxroot" -type f | wc -l)
  if [[ $st -eq 3 && "$before" -eq "$after" ]]; then ok "$label rejected with exit 3, nothing written"
  else bad "$label must exit 3 and write nothing (exit $st, files $before -> $after)"; fi
}
mut() { printf '%s\n' "$GOOD_ROW" | awk -F'\t' -v f="$1" -v v="$2" 'BEGIN{OFS="\t"}{$f=v; print}'; }
fixture "unexpected tier letter"                    mut 2 Z
fixture "unexpected depth value"                    mut 3 someday
fixture "Tier A up_hash of the wrong length"        mut 8 abcdef
fixture "Tier A up_hash set to a placeholder"       mut 8 '-'
fixture "Tier A up_hash set to PENDING"             mut 8 PENDING
fixture "unsupported upstream algorithm"            mut 7 crc32
fixture "non-https up_hash_src"                     mut 9 'http://example.invalid/x'
fixture "Tier A without a saved artifact"           mut 10 '-'
fixture "malformed up_fetched"                      mut 11 'yesterday'
row_pin_as_up() { printf '%s\n' "$GOOD_ROW" | awk -F'\t' 'BEGIN{OFS="\t"}{$5=$8; print}'; }
row_http_url()  { printf '%s\n' "$GOOD_ROW" | awk -F'\t' 'BEGIN{OFS="\t"}{sub(/^https:/,"http:",$12); print}'; }
fixture "sha256 pin reused as the upstream hash"    row_pin_as_up
fixture "non-https retrieval url"                   row_http_url

sect "cross-document coverage"
mapfile -t MPATHS < <(tail -n +2 "$MANIFEST" | cut -f1 | grep -v '^#' | grep -v '^$')
mapfile -t RPATTERNS < <(grep -oE '^[[:space:]]*(PXD022198|PXD022216)/[^[:space:]]+' "$README" \
                          | sed -E 's/^[[:space:]]+//' | sort -u)
mapfile -t PPATTERNS < <(grep -oE '^\| `(PXD022198|PXD022216)/[^`]+`' "$PROV" | sed -E 's/^\| `//; s/`$//' | sort -u)
cover() { # <label> <patterns...>
  local label="$1"; shift
  local -a pats=("$@")
  [[ ${#pats[@]} -gt 0 ]] || { bad "$label: no patterns found"; return; }
  local p pat i uncovered=0 dup=0 unused=0
  local -a hits
  for ((i=0;i<${#pats[@]};i++)); do hits[i]=0; done
  for p in "${MPATHS[@]}"; do
    local n=0
    for ((i=0;i<${#pats[@]};i++)); do
      pat="${pats[i]}"
      # shellcheck disable=SC2053
      if [[ "$p" == $pat ]]; then n=$((n+1)); hits[i]=$((hits[i]+1)); fi
    done
    if [[ $n -eq 0 ]]; then uncovered=$((uncovered+1)); printf '      uncovered: %s\n' "$p"
    elif [[ $n -gt 1 ]]; then dup=$((dup+1)); printf '      matched by %d patterns: %s\n' "$n" "$p"; fi
  done
  for ((i=0;i<${#pats[@]};i++)); do
    [[ ${hits[i]} -eq 0 ]] && { unused=$((unused+1)); printf '      pattern matches nothing: %s\n' "${pats[i]}"; }
  done
  if [[ $uncovered -eq 0 && $dup -eq 0 && $unused -eq 0 ]]; then
    ok "$label: ${#MPATHS[@]} manifest paths each covered exactly once by ${#pats[@]} patterns"
  else
    bad "$label: $uncovered uncovered, $dup multiply covered, $unused unused patterns"
  fi
}
cover "README directory tree"        "${RPATTERNS[@]}"
cover "PROVENANCE file descriptions" "${PPATTERNS[@]}"

sect "statistics section"
mapfile -t STATFILES < <(awk -F'|' '/^\| *`?(PXD022198|PXD022216)/ {print $2}' "$README" \
  | sed -E 's/^ *`?//; s/`? *$//' | grep -E '^(PXD022198|PXD022216)/' | sort -u)
if [[ ${#STATFILES[@]} -eq 0 ]]; then
  if grep -q 'Not yet computed' "$README"; then
    ok "statistics section declares itself not yet computed (nothing downloaded at this baseline)"
  else
    bad "statistics section names no file and does not say why"
  fi
else
  missing=0
  for f in "${STATFILES[@]}"; do
    cut -f1 "$MANIFEST" | grep -Fxq "$f" || { missing=$((missing+1)); printf '      not in MANIFEST: %s\n' "$f"; }
  done
  [[ $missing -eq 0 ]] && ok "all ${#STATFILES[@]} file(s) in the statistics table exist in MANIFEST.tsv" \
    || bad "$missing file(s) in the statistics table are not in MANIFEST.tsv"
  if grep -q 'matrix_stats.py' "$README"; then
    ninv=$(grep -c 'matrix_stats.py' "$README")
    ok "statistics table carries $ninv recorded matrix_stats.py invocation line(s)"
  else
    bad "statistics table has no recorded invocation"
  fi
  if grep -Eq 'Missing-value convention' "$README"; then
    ok "missing-value convention is stated alongside the statistics"
  else
    bad "no missing-value convention stated for the completeness figures"
  fi
fi

sect "anti-laundering"
if grep -Enq -e '(uhash|up_hash|M_UHASH)[^=]*=[^=].*(sha1sum|sha256sum|md5sum|hash_with_algo)' "$DL"; then
  bad "a code path assigns a locally computed hash into an upstream field"
  grep -Ens -e '(uhash|up_hash|M_UHASH)[^=]*=[^=].*(sha1sum|sha256sum|md5sum|hash_with_algo)' "$DL" | sed 's/^/      /'
else
  ok "no code path writes a computed hash into an upstream column"
fi
WSITE='>[[:space:]]*"\$MANIFEST"|mv[[:print:]]*"\$MANIFEST"'
rw="$(grep -Ec -e "$WSITE" "$DL")"
inw="$(awk '/^write_pin\(\)/,/^}/'        "$DL" | grep -Ec -e "$WSITE")"
inr="$(awk '/^refresh_manifest\(\)/,/^}/' "$DL" | grep -Ec -e "$WSITE")"
if [[ "$rw" -ge 1 && "$rw" -eq $((inw + inr)) ]]; then
  ok "MANIFEST.tsv is written only by write_pin() and refresh_manifest() ($inw + $inr sites)"
else
  bad "MANIFEST.tsv written outside write_pin()/refresh_manifest() ($rw total, $inw + $inr accounted for)"
fi
# write_pin must only ever touch the local-observation triple, fields 4-6.
if awk '/^write_pin\(\)/,/^}/' "$DL" | grep -Eq '\$(7|8|9|1[0-2]) *='; then
  bad "write_pin() assigns a field outside the local-observation triple"
else
  ok "write_pin() assigns only fields 4-6 (bytes, sha256, pinned_date)"
fi

sect "depth behaviour"
for d in default supplementary raw bogus; do
  ( cd "$SANDBOX" && bash "$DL" "$d" --verify-only ) >"$SANDBOX/vd_$d.txt" 2>&1; st=$?
  if [[ "$d" == bogus ]]; then
    [[ $st -eq 2 ]] && ok "unknown depth positional exits 2" || bad "unknown depth must exit 2 (got $st)"
  else
    if [[ $st -eq 0 || $st -eq 1 ]]; then ok "--verify-only $d exits $st (never 2 or 3)"
    else bad "--verify-only $d exited $st"; sed 's/^/      /' "$SANDBOX/vd_$d.txt" | tail -5; fi
  fi
done
# Out-of-depth rows must be out-of-scope, never missing.
oos=$(grep -c '^OUT-OF-SCOPE' "$SANDBOX/vd_default.txt")
mraw=$(grep -cE '^(MISSING|NOT_YET_DOWNLOADED).*(\.raw|\.d\.zip|\.sne)' "$SANDBOX/vd_default.txt")
if [[ "$oos" -gt 0 && "$mraw" -eq 0 ]]; then
  ok "at depth default the $oos raw-depth rows are out-of-scope, not missing"
else
  bad "depth default mislabelled out-of-depth rows (out-of-scope=$oos, raw rows reported present/missing=$mraw)"
fi
[[ "$(grep -c '^OUT-OF-SCOPE' "$SANDBOX/vd_raw.txt")" -eq 0 ]] \
  && ok "at depth raw nothing is out of scope" || bad "depth raw reported out-of-scope rows"

sect "sandbox dry-run writes nothing"
DRYM="$SANDBOX/dry.tsv"
{ printf '%s\n' "$HDR"
  awk -F'\t' 'BEGIN{OFS="\t"} NR>1 && $3=="default" {$12="https://example.invalid/d"; print; exit}' "$MANIFEST"
} > "$DRYM"
mkdir -p "$SANDBOX/dryroot"
before=$(find "$SANDBOX/dryroot" | wc -l)
( cd "$SANDBOX" && bash "$DL" --dry-run --manifest "$DRYM" --root "$SANDBOX/dryroot" >/dev/null 2>&1 ); st=$?
after=$(find "$SANDBOX/dryroot" | wc -l)
if [[ $st -eq 0 && "$before" -eq "$after" ]]; then ok "--dry-run exits 0 and creates nothing"
else bad "--dry-run: exit $st, files $before -> $after"; fi

sect "--verify-only against the real directory"
for d in default raw; do
  vst=0; grep -q . "$SANDBOX/vd_$d.txt" || vst=99
  ( cd "$SANDBOX" && bash "$DL" "$d" --verify-only ) >"$SANDBOX/vo_$d.txt" 2>&1; vst=$?
  nok=$(grep -c '^OK ' "$SANDBOX/vo_$d.txt")
  mism=$(grep -c '^MISMATCH' "$SANDBOX/vo_$d.txt")
  miss=$(grep -c '^MISSING' "$SANDBOX/vo_$d.txt")
  unp=$(grep -c '^UNPINNED' "$SANDBOX/vo_$d.txt")
  nyd=$(grep -c '^NOT_YET_DOWNLOADED' "$SANDBOX/vo_$d.txt")
  if [[ "$mism" -eq 0 && "$miss" -eq 0 && "$unp" -eq 0 ]]; then
    ok "depth $d verifies clean: $nok OK, $nyd not yet downloaded (exit $vst)"
  else
    bad "depth $d: $mism MISMATCH, $miss MISSING, $unp UNPINNED"
    grep -E '^(MISMATCH|MISSING|UNPINNED)' "$SANDBOX/vo_$d.txt" | head -5 | sed 's/^/      /'
  fi
done

sect "no test wrote to the real manifest"
if [[ "$(sha256sum "$MANIFEST" | awk '{print $1}')" == "$MSUM_BEFORE" ]]; then
  ok "MANIFEST.tsv is byte-identical to how the run started"
else
  bad "MANIFEST.tsv changed during the test run"
fi

sect "version control"
if git -C "$SCRIPT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  if git -C "$SCRIPT_DIR" ls-files --error-unmatch MANIFEST.tsv >/dev/null 2>&1; then
    ok "MANIFEST.tsv is tracked"
    if [[ -z "$(git -C "$SCRIPT_DIR" status --porcelain -- MANIFEST.tsv)" ]]; then
      ok "MANIFEST.tsv is clean relative to HEAD"
    else
      bad "MANIFEST.tsv is tracked but dirty — an unattributed baseline change is sitting in the tree"
    fi
    ncommit=$(git -C "$SCRIPT_DIR" rev-list --count HEAD -- MANIFEST.tsv 2>/dev/null || echo 0)
    [[ "$ncommit" -ge 1 ]] && ok "MANIFEST.tsv has $ncommit commit(s) of history" \
      || bad "MANIFEST.tsv has no commit history"
  else
    bad "MANIFEST.tsv is not tracked by git"
  fi
  tracked_data=0
  while read -r p; do
    git -C "$SCRIPT_DIR" ls-files --error-unmatch -- "$p" >/dev/null 2>&1 && {
      tracked_data=$((tracked_data+1)); printf '      data file is tracked: %s\n' "$p"; }
  done < <(tail -n +2 "$MANIFEST" | cut -f1)
  [[ $tracked_data -eq 0 ]] && ok "no data file listed in MANIFEST.tsv is tracked by git" \
    || warn "$tracked_data data file(s) are tracked — history will grow without bound; MANIFEST.tsv plus DOWNLOAD.sh is the intended record"
else
  warn "not a git repository — the audit trail behind Hard Rule 7 does not exist, so a manifest change cannot be attributed"
fi

# =============================================================== network ===
if [[ "${DATASET_TEST_NETWORK:-0}" != '1' ]]; then
  sect "network checks"
  skip "network section disabled (set DATASET_TEST_NETWORK=1 to enable)"
  skip "  authority check: re-fetch every up_hash_src and compare"
  skip "  reachability: HEAD every retrieval url"
  skip "  live download of the smallest default-depth file into the sandbox"
  skip "  the live download turns its PENDING row into a full pin"
  skip "  404 handling leaves no stub behind"
  skip "  corruption of a sandbox copy is detected by --verify-only"
else
  sect "network: authority check"
  mapfile -t SRCS < <(tail -n +2 "$MANIFEST" | awk -F'\t' '$9 != "-" {print $9}' | sort -u)
  for s in "${SRCS[@]}"; do
    f="$SANDBOX/auth.$(printf '%s' "$s" | tr -c 'A-Za-z0-9' '_')"
    if ! curl -fsL -m 300 --retry 3 --retry-delay 5 --proto '=https' --tlsv1.2 -o "$f" -- "$s"; then
      bad "could not re-fetch $s"; continue
    fi
    n=0; miss=0
    while IFS=$'\t' read -r path tier _d _b _s2 _pd _ua uhash usrc _uc _uf _u; do
      [[ "$path" == \#* || -z "$path" ]] && continue
      [[ "$tier" == 'A' && "$usrc" == "$s" ]] || continue
      n=$((n+1))
      grep -Fq -- "$uhash" "$f" || { miss=$((miss+1)); printf '      no longer published: %s (%s)\n' "$path" "$uhash"; }
    done < <(tail -n +2 "$MANIFEST")
    if [[ $miss -eq 0 ]]; then ok "authority still publishes all $n hashes from $s"
    else bad "$miss of $n manifest hashes no longer match $s"; fi
  done

  sect "network: reachability"
  nbad=0; ntot=0
  while IFS=$'\t' read -r path _t _d _b _s _pd _ua _uh _us _uc _uf url; do
    [[ "$path" == \#* || -z "$path" ]] && continue
    ntot=$((ntot+1))
    code="$(curl -fsIL -m 120 --retry 2 --retry-delay 3 --proto '=https' --tlsv1.2 -o /dev/null -w '%{http_code}' -- "$url" 2>/dev/null || echo 000)"
    [[ "$code" == '200' ]] || { nbad=$((nbad+1)); printf '      HTTP %s  %s\n' "$code" "$url"; }
  done < <(tail -n +2 "$MANIFEST")
  if [[ $nbad -eq 0 ]]; then ok "all $ntot retrieval URLs answer HTTP 200"
  else bad "$nbad of $ntot retrieval URLs do not answer HTTP 200"; fi

  sect "network: live download of the smallest default-depth entry"
  # Build a one-row sandbox manifest with the row forced back to PENDING, so the
  # run exercises the real PENDING -> pinned transition without touching the
  # real manifest.
  SMALL="$(tail -n +2 "$MANIFEST" | awk -F'\t' '$2=="A" && $3=="default" {print $1}' \
           | while read -r p; do printf '%s\t%s\n' "$(awk -F'\t' -v q="$p" '$1==q{print $4}' "$MANIFEST")" "$p"; done \
           | grep -v '^PENDING' | sort -n | head -n 1 | cut -f2)"
  [[ -n "$SMALL" ]] || SMALL="$(tail -n +2 "$MANIFEST" | awk -F'\t' '$2=="A" && $3=="default" {print $1; exit}' "$MANIFEST")"
  LIVEM="$SANDBOX/live.tsv"
  { printf '%s\n' "$HDR"
    awk -F'\t' -v OFS='\t' -v p="$SMALL" '$1==p {$4="PENDING"; $5="PENDING"; $6="PENDING"; print}' "$MANIFEST"
  } > "$LIVEM"
  mkdir -p "$SANDBOX/liveroot"
  ( cd "$SANDBOX" && bash "$DL" default --manifest "$LIVEM" --root "$SANDBOX/liveroot" >"$SANDBOX/live1.txt" 2>&1 ); st=$?
  F="$SANDBOX/liveroot/$SMALL"
  if [[ $st -eq 0 && -f "$F" ]]; then ok "downloaded $SMALL and its Tier A hash matched"
  else bad "live download of $SMALL failed (exit $st)"; sed 's/^/      /' "$SANDBOX/live1.txt"; fi
  if [[ -f "$F" ]]; then
    mode="$(stat -c '%a' "$F")"
    [[ "$mode" == '444' ]] && ok "installed file mode is 444" || bad "installed file mode is $mode, expected 444"
    npend=$(awk -F'\t' -v p="$SMALL" '$1==p && ($4=="PENDING" || $5=="PENDING" || $6=="PENDING")' "$LIVEM" | wc -l)
    [[ "$npend" -eq 0 ]] && ok "the row left PENDING and now carries all three pin fields" \
      || bad "the row is still PENDING after a successful download"
    mt1="$(stat -c '%Y' "$F")"
    ( cd "$SANDBOX" && bash "$DL" default --manifest "$LIVEM" --root "$SANDBOX/liveroot" >"$SANDBOX/live2.txt" 2>&1 ); st2=$?
    mt2="$(stat -c '%Y' "$F")"
    if [[ $st2 -eq 0 ]] && grep -q 'SKIP complete' "$SANDBOX/live2.txt"; then ok "second run reports it complete and downloads nothing"
    else bad "second run did not skip (exit $st2)"; sed 's/^/      /' "$SANDBOX/live2.txt"; fi
    [[ "$mt1" == "$mt2" ]] && ok "mtime unchanged by the second run" || bad "mtime changed on the second run"

    sect "network: corruption handling"
    chmod u+w "$F"; printf 'x' >> "$F"
    ( cd "$SANDBOX" && bash "$DL" default --verify-only --manifest "$LIVEM" --root "$SANDBOX/liveroot" ) >"$SANDBOX/corrupt.txt" 2>&1; cst=$?
    if [[ $cst -ne 0 ]] && grep -q '^MISMATCH' "$SANDBOX/corrupt.txt"; then ok "--verify-only detects the altered file and exits non-zero"
    else bad "--verify-only did not detect corruption (exit $cst)"; sed 's/^/      /' "$SANDBOX/corrupt.txt"; fi
  fi

  sect "network: 404 handling"
  FOURM="$SANDBOX/four.tsv"
  { printf '%s\n' "$HDR"
    awk -F'\t' -v OFS='\t' -v p="$SMALL" '$1==p {$4="PENDING"; $5="PENDING"; $6="PENDING"; $12=$12".definitely-not-here"; print}' "$MANIFEST"
  } > "$FOURM"
  mkdir -p "$SANDBOX/fourroot"
  ( cd "$SANDBOX" && bash "$DL" default --manifest "$FOURM" --root "$SANDBOX/fourroot" >/dev/null 2>&1 ); st=$?
  leftover=$(find "$SANDBOX/fourroot" -type f | wc -l)
  if [[ $st -ne 0 && "$leftover" -eq 0 ]]; then ok "a 404 URL exits non-zero and leaves no file behind"
  else bad "404 handling: exit $st, $leftover file(s) left in the sandbox"; fi
fi

printf '\n%d passed, %d failed, %d skipped, %d warnings\n' "$PASS" "$FAIL" "$SKIP" "$WARN"
[[ "$FAIL" -eq 0 ]]
