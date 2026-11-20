#!/usr/bin/env bash
# Counts full-line comments per file and holds the count with a ratchet: a file may lose comments,
# never gain them. For the prune-comments skill, and copied into a project to run in CI.
#
#   comment-ratchet.sh count [path...]   comment lines per file, then a total
#   comment-ratchet.sh init [path...]    write .comment-baseline for these paths (default: .)
#   comment-ratchet.sh check             fail when a file has more comment lines than its baseline
#   comment-ratchet.sh tighten           lower baseline counts to today's, never raise one
#
# Counted: whole lines that are // or /* */ comments (C-style languages) or # comments (Python,
# Ruby, shell, PHP). Not counted: trailing comments after code, docblocks and doc comments
# (/** */, ///, //!, Python docstrings), license headers, shebangs, and tool directives such as
# eslint-disable, @ts-expect-error, @phpstan-ignore, noqa or go:build.
#
# Skipped paths: vendor/, node_modules/, dist/, build/, coverage/, third_party/, .scratch/,
# minified files and .d.ts files, plus every extended regex in .comment-ratchet-ignore (one per
# line, matched against the repo-relative path).
#
# To keep a new comment on purpose, raise that file's count in .comment-baseline in the same
# change, so the review sees it.
set -euo pipefail

BASELINE=.comment-baseline
IGNORE_FILE=.comment-ratchet-ignore
DEFAULT_IGNORE='(^|/)(vendor|node_modules|dist|build|coverage|third_party|\.scratch)/|\.min\.(js|css)$|\.d\.[cm]?ts$'
EXTS='\.(js|jsx|mjs|cjs|ts|tsx|mts|cts|vue|svelte|php|go|java|kt|kts|swift|rs|c|h|cc|cpp|hpp|cs|scala|dart|groovy|py|rb|sh|bash|zsh)$'

# No backslashes: awk -v would read them as escapes.
DIRECTIVES='eslint-|@ts-(ignore|expect-error|nocheck|check)|prettier-ignore|biome-ignore|istanbul ignore|c8 ignore|v8 ignore|@phpstan-|@psalm-|phpcs:|@codeCoverageIgnore|@infection-ignore|noqa|type: *ignore|pyright: *ignore|pylint: *disable|fmt: *(off|on|skip)|rubocop:(disable|enable|todo)|swiftlint:|NOLINT|nolint|go:(build|generate|embed|linkname)|[+]build |@generated|DO NOT EDIT|webpackChunkName|@vite-ignore|-[*]- coding|frozen_string_literal|shellcheck (disable|source)|@jsx|@refresh reset|#(end)?region|# *pragma'
LICENSE='Copyright|SPDX-License-Identifier|@license|^/[*]!'

# Per file: comment lines in groups (a run of line comments, or one block comment). A group with a
# license line is skipped whole; a directive line is skipped on its own.
read -r -d '' PROG <<'AWK' || true
function take(s) { if (s ~ LIC) lic = 1; else if (s !~ DIR) gn++ }
function flush() { if (!lic) n += gn; gn = 0; lic = 0 }
function emit() { flush(); if (file != "" && n > 0) printf "%d\t%s\n", n, file }
FNR == 1 {
  emit(); file = FILENAME; n = 0; inblock = 0; doc = 0
  ext = tolower(file); sub(/.*[.]/, "", ext)
  c = ext ~ /^(js|jsx|mjs|cjs|ts|tsx|mts|cts|vue|svelte|php|go|java|kt|kts|swift|rs|c|h|cc|cpp|hpp|cs|scala|dart|groovy)$/
  h = ext ~ /^(py|rb|sh|bash|zsh|php)$/
}
{
  s = $0; sub(/^[ \t]+/, "", s)
  if (inblock) {
    if (!doc) take(s)
    if (index(s, "*/")) { inblock = 0; if (!doc) flush(); doc = 0 }
    next
  }
  if (c && substr(s, 1, 2) == "/*") {
    flush()
    doc = substr(s, 1, 3) == "/**" && substr(s, 1, 4) != "/**/"
    if (!doc) take(s)
    if (index(substr(s, 3), "*/")) { if (!doc) flush(); doc = 0 } else inblock = 1
    next
  }
  if (c && (substr(s, 1, 3) == "///" || substr(s, 1, 3) == "//!")) next
  if (c && substr(s, 1, 2) == "//") { take(s); next }
  if (h && substr(s, 1, 1) == "#" && substr(s, 1, 2) != "#[" && !(FNR == 1 && substr(s, 1, 2) == "#!")) { take(s); next }
  flush()
}
END { emit() }
AWK

die() { echo "comment-ratchet: $*" >&2; exit 2; }
self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")

git rev-parse --show-toplevel >/dev/null 2>&1 || die "run inside a git repository"
cd "$(git rev-parse --show-toplevel)"

files() {
  local ignore=$DEFAULT_IGNORE
  if [ -f "$IGNORE_FILE" ]; then
    local extra
    extra=$(grep -v '^[[:space:]]*$' "$IGNORE_FILE" | grep -v '^#' | paste -sd'|' - || true)
    [ -n "$extra" ] && ignore="$ignore|$extra"
  fi
  git ls-files -- "$@" | grep -E "$EXTS" | grep -Ev "$ignore" || true
}

# Prints "count<TAB>path" for each file with comments, sorted by path.
count() {
  local list
  list=$(files "$@")
  [ -n "$list" ] || return 0
  printf '%s\n' "$list" | tr '\n' '\0' \
    | xargs -0 awk -v DIR="$DIRECTIVES" -v LIC="$LICENSE" "$PROG" \
    | sort -t "$(printf '\t')" -k2
}

scope() { sed -n 's/^# scope: //p' "$BASELINE"; }
entries() { grep -v '^#' "$BASELINE" || true; }

write_baseline() {
  { echo "# Comment lines per file (comment-ratchet.sh). Counts may go down, never up."
    echo "# scope: $1"
    cat; } > "$BASELINE.tmp"
  mv "$BASELINE.tmp" "$BASELINE"
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case "$cmd" in
  count)
    [ $# -gt 0 ] || set -- .
    out=$(count "$@")
    [ -n "$out" ] && printf '%s\n' "$out"
    printf '%s\n' "$out" | awk -F'\t' 'NF == 2 {n += $1; f++} END {printf "# total: %d comment lines in %d files\n", n, f}'
    ;;
  init)
    [ ! -e "$BASELINE" ] || die "$BASELINE exists. Use tighten, or delete it first"
    [ $# -gt 0 ] || set -- .
    count "$@" | write_baseline "$*"
    echo "comment-ratchet: wrote $BASELINE ($(entries | awk -F'\t' '{n += $1} END {print n + 0}') comment lines)"
    ;;
  check)
    [ -f "$BASELINE" ] || die "no $BASELINE. Run: comment-ratchet.sh init [path...]"
    # shellcheck disable=SC2046
    current=$(count $(scope))
    printf '%s\n' "$current" | awk -F'\t' -v base="$BASELINE" '
      BEGIN { while ((getline l < base) > 0) if (l !~ /^#/) { split(l, a, "\t"); b[a[2]] = a[1] } }
      NF == 2 {
        was = ($2 in b) ? b[$2] : 0
        if ($1 > was) { printf "%s: %d comment lines, baseline %d\n", $2, $1, was; bad++ }
        else if ($1 < was) down++
        seen[$2] = 1
      }
      END {
        for (f in b) if (!(f in seen)) down++
        if (bad) { printf "comment-ratchet: %d file(s) gained comments. Remove them, or raise the count in %s on purpose\n", bad, base; exit 1 }
        if (down) printf "comment-ratchet: ok, %d file(s) below baseline. Run tighten to lock that in\n", down
        else print "comment-ratchet: ok"
      }'
    ;;
  tighten)
    [ -f "$BASELINE" ] || die "no $BASELINE. Run: comment-ratchet.sh init [path...]"
    s=$(scope)
    # shellcheck disable=SC2086
    current=$(count $s)
    printf '%s\n' "$current" | awk -F'\t' -v base="$BASELINE" '
      BEGIN { while ((getline l < base) > 0) if (l !~ /^#/) { split(l, a, "\t"); b[a[2]] = a[1] } }
      NF == 2 && ($2 in b) { printf "%d\t%s\n", ($1 < b[$2] ? $1 : b[$2]), $2 }' \
      | sort -t "$(printf '\t')" -k2 | write_baseline "$s"
    echo "comment-ratchet: $BASELINE now holds $(entries | awk -F'\t' '{n += $1} END {print n + 0}') comment lines"
    ;;
  *)
    sed -n '2,20p' "$self" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
