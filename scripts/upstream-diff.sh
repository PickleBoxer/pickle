#!/usr/bin/env bash
# Maintainer only. Lists what changed in upstream pstack (cursor/plugins, pstack/) since the
# baseline in UPSTREAM.md: new version, new commits, a diff stat per tracked row, and
# upstream files no row covers. Fetches the clone, moves no branch.
#
# Usage: bash scripts/upstream-diff.sh [-p]     -p prints full diffs instead of stats
# Env:   PSTACK_UPSTREAM_DIR, a clone of https://github.com/cursor/plugins
#        (default ~/dev/code/cursor-plugins)
set -euo pipefail
cd "$(dirname "$0")/.."

full=0; [ "${1:-}" = "-p" ] && full=1
repo=${PSTACK_UPSTREAM_DIR:-$HOME/dev/code/cursor-plugins}
if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  echo "upstream-diff: no cursor/plugins clone at $repo. Clone it once:" >&2
  echo "  git clone --filter=blob:none https://github.com/cursor/plugins.git $repo" >&2
  exit 1
fi
g() { git -C "$repo" "$@"; }

base=$(awk -F'|' '$2 ~ /^ pstack $/ {gsub(/ /, "", $5); print $5}' UPSTREAM.md)
[ -n "$base" ] || { echo "upstream-diff: no pstack Commit in UPSTREAM.md" >&2; exit 1; }

g fetch -q origin
new=$(g rev-parse origin/HEAD)

version() { g show "$1:pstack/.cursor-plugin/plugin.json" | sed -nE 's/.*"version": *"([^"]+)".*/\1/p'; }
echo "Baseline: $(version "$base") at ${base:0:7}"
echo "Upstream: $(version "$new") at ${new:0:7}"

if [ -z "$(g log --oneline "$base..$new" -- pstack)" ]; then
  echo "No pstack changes since the baseline."
  exit 0
fi

echo
echo "## Commits touching pstack/"
g log --oneline "$base..$new" -- pstack

rows=$(awk -F'|' 'NF>=8 && $3 ~ /^ (skill|playbook|principle|agent|script|mod|automation) $/ {
  for (i=2; i<=6; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $4 "|" $5}' UPSTREAM.md)

echo
echo "## Changed rows"
sources=""
while IFS='|' read -r item src rel; do
  [ "$src" = "-" ] && continue
  case "$src" in port:*) continue;; esac
  IFS=',' read -ra paths <<< "$src"
  paths=("${paths[@]# }")
  paths=("${paths[@]/#/pstack/}")
  sources="$sources ${paths[*]}"
  stat=$(g diff --stat "$base" "$new" -- "${paths[@]}")
  [ -n "$stat" ] || continue
  echo
  echo "### $item ($rel) <- $src"
  if [ "$full" = 1 ]; then g diff "$base" "$new" -- "${paths[@]}"; else echo "$stat"; fi
done <<< "$rows"

echo
echo "## Upstream files no row covers"
g diff --name-only --diff-filter=A "$base" "$new" -- pstack/skills pstack/agents | while read -r f; do
  covered=0
  for s in $sources; do case "$f" in "$s"|"$s"/*) covered=1; break;; esac; done
  [ "$covered" = 1 ] || echo "$f"
done

echo
echo "Rows with a port: source exist only in PickleBoxer/pstack and are not diffed."
echo "Per row: take, ignore or note the change, bump its Upstream version, then the baseline when all rows are done."
