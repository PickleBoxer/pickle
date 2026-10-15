#!/usr/bin/env bash
# Maintainer only. Lists what changed upstream since each baseline in UPSTREAM.md: pstack/ and
# cursor-team-kit/ (kit: rows) in cursor/plugins, and addyosmani/agent-skills (as: rows). Per
# source: new version, new commits, a diff stat per tracked row, and (pstack, agent-skills)
# upstream files no row covers. Fetches the clones, moves no branch.
#
# Usage: bash scripts/upstream-diff.sh [-p]     -p prints full diffs instead of stats
# Env:   PSTACK_UPSTREAM_DIR, a clone of https://github.com/cursor/plugins
#        (default ~/dev/code/cursor-plugins)
#        AGENT_SKILLS_UPSTREAM_DIR, a clone of https://github.com/addyosmani/agent-skills
#        (default ~/dev/code/agent-skills)
set -euo pipefail
cd "$(dirname "$0")/.."

full=0; [ "${1:-}" = "-p" ] && full=1
plugins=${PSTACK_UPSTREAM_DIR:-$HOME/dev/code/cursor-plugins}
agentskills=${AGENT_SKILLS_UPSTREAM_DIR:-$HOME/dev/code/agent-skills}

# Sources: UPSTREAM.md Baseline name | clone | folder in the clone | source prefix in rows |
# manifest with the version | list upstream files no row covers (1) or only the taken rows (0).
sources_tbl="pstack|$plugins|pstack||.cursor-plugin/plugin.json|1
cursor-team-kit|$plugins|cursor-team-kit|kit:|.cursor-plugin/plugin.json|0
agent-skills|$agentskills|.|as:|.claude-plugin/plugin.json|1"

rows=$(awk -F'|' 'NF>=8 && $3 ~ /^ (skill|playbook|principle|agent|script|mod|automation) $/ {
  for (i=2; i<=6; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $4 "|" $5}' UPSTREAM.md)

while IFS='|' read -r name repo dir prefix manifest whole; do
  if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    url=https://github.com/cursor/plugins.git
    [ "$name" = agent-skills ] && url=https://github.com/addyosmani/agent-skills.git
    echo "upstream-diff: no $name clone at $repo. Clone it once:" >&2
    echo "  git clone --filter=blob:none $url $repo" >&2
    exit 1
  fi
  g() { git -C "$repo" "$@"; }
  g fetch -q origin
  new=$(g rev-parse origin/HEAD)
  pre="$dir/"; [ "$dir" = . ] && pre=""
  base=$(awk -F'|' -v n=" $name " '$2 == n {gsub(/ /, "", $5); print $5}' UPSTREAM.md)
  [ -n "$base" ] || { echo "upstream-diff: no $name Commit in UPSTREAM.md" >&2; exit 1; }
  version() { g show "$1:$pre$manifest" | sed -nE 's/.*"version": *"([^"]+)".*/\1/p'; }

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
    paths=("${paths[@]/#/$pre}")
    sources="$sources ${paths[*]}"
    stat=$(g diff --stat "$base" "$new" -- "${paths[@]}")
    [ -n "$stat" ] || continue
    echo
    echo "### $item ($rel) <- $src"
    if [ "$full" = 1 ]; then g diff "$base" "$new" -- "${paths[@]}"; else echo "$stat"; fi
  done <<< "$rows"

  # pstack and agent-skills are tracked as a whole. For the kit, only the rows pickle took.
  if [ "$whole" = 1 ]; then
    echo
    echo "## Upstream files no row covers"
    g diff --name-only --diff-filter=A "$base" "$new" -- "${pre}skills" "${pre}agents" | while read -r f; do
      c=0
      for s in $sources; do case "$f" in "$s"|"$s"/*) c=1; break;; esac; done
      [ "$c" = 1 ] || echo "$f"
    done
  fi
  echo
done <<< "$sources_tbl"

echo "Rows with a port: source exist only in PickleBoxer/pstack and are not diffed."
echo "Per row: take, ignore or note the change, bump its Upstream version, then that source's baseline when all its rows are done."
