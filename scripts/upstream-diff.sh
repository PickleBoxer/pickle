#!/usr/bin/env bash
# Maintainer only. Lists what changed upstream in cursor/plugins since each baseline in
# UPSTREAM.md: pstack/, and cursor-team-kit/ for kit: rows. Per source: new version, new
# commits, a diff stat per tracked row, and (pstack only) upstream files no row covers. Fetches the clone, moves no branch.
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

# Sources: UPSTREAM.md Baseline name | folder in cursor/plugins | source prefix in rows.
sources_tbl="pstack|pstack|
cursor-team-kit|cursor-team-kit|kit:"

g fetch -q origin
new=$(g rev-parse origin/HEAD)

rows=$(awk -F'|' 'NF>=8 && $3 ~ /^ (skill|playbook|principle|agent|script|mod|automation) $/ {
  for (i=2; i<=6; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $4 "|" $5}' UPSTREAM.md)

while IFS='|' read -r name dir prefix; do
  base=$(awk -F'|' -v n=" $name " '$2 == n {gsub(/ /, "", $5); print $5}' UPSTREAM.md)
  [ -n "$base" ] || { echo "upstream-diff: no $name Commit in UPSTREAM.md" >&2; exit 1; }
  version() { g show "$1:$dir/.cursor-plugin/plugin.json" | sed -nE 's/.*"version": *"([^"]+)".*/\1/p'; }

  echo "# $name ($dir/)"
  echo
  echo "Baseline: $(version "$base") at ${base:0:7}"
  echo "Upstream: $(version "$new") at ${new:0:7}"
  if [ -z "$(g log --oneline "$base..$new" -- "$dir")" ]; then
    echo "No $name changes since the baseline."
    echo
    continue
  fi

  echo
  echo "## Commits touching $dir/"
  g log --oneline "$base..$new" -- "$dir"

  echo
  echo "## Changed rows"
  sources=""
  while IFS='|' read -r item src rel; do
    [ "$src" = "-" ] && continue
    case "$src" in port:*) continue;; esac
    if [ -n "$prefix" ]; then
      case "$src" in "$prefix"*) src_paths=${src#"$prefix"};; *) continue;; esac
    else
      case "$src" in *:*) continue;; esac
      src_paths=$src
    fi
    IFS=',' read -ra paths <<< "$src_paths"
    paths=("${paths[@]# }")
    paths=("${paths[@]/#/$dir/}")
    sources="$sources ${paths[*]}"
    stat=$(g diff --stat "$base" "$new" -- "${paths[@]}")
    [ -n "$stat" ] || continue
    echo
    echo "### $item ($rel) <- $src"
    if [ "$full" = 1 ]; then g diff "$base" "$new" -- "${paths[@]}"; else echo "$stat"; fi
  done <<< "$rows"

  # Only pstack is tracked as a whole. For the kit, only the rows pickle took.
  if [ -z "$prefix" ]; then
    echo
    echo "## Upstream files no row covers"
    g diff --name-only --diff-filter=A "$base" "$new" -- "$dir/skills" "$dir/agents" | while read -r f; do
      c=0
      for s in $sources; do case "$f" in "$s"|"$s"/*) c=1; break;; esac; done
      [ "$c" = 1 ] || echo "$f"
    done
  fi
  echo
done <<< "$sources_tbl"

echo "Rows with a port: source exist only in PickleBoxer/pstack and are not diffed."
echo "Per row: take, ignore or note the change, bump its Upstream version, then that source's baseline when all its rows are done."
