#!/usr/bin/env bash
# Maintainer only. Lists what changed upstream since UPSTREAM.md last looked: pstack/ in
# cursor/plugins, addyosmani/agent-skills (as: rows) and mattpocock/skills (mp: rows). Per source: new version, new commits
# since the Baseline, a diff stat per row and per graft from its own Commit, and (agent-skills) upstream
# files no row covers. Fetches the clones, moves no branch.
#
# Usage: bash scripts/upstream-diff.sh [-p]     -p prints full diffs instead of stats
# Env:   PSTACK_UPSTREAM_DIR, a clone of https://github.com/cursor/plugins
#        (default ~/dev/code/cursor-plugins)
#        AGENT_SKILLS_UPSTREAM_DIR, a clone of https://github.com/addyosmani/agent-skills
#        (default ~/dev/code/agent-skills)
#        MP_SKILLS_UPSTREAM_DIR, a clone of https://github.com/mattpocock/skills
#        (default ~/dev/code/mattpocock-skills)
set -euo pipefail
cd "$(dirname "$0")/.."

full=0; [ "${1:-}" = "-p" ] && full=1
plugins=${PSTACK_UPSTREAM_DIR:-$HOME/dev/code/cursor-plugins}
agentskills=${AGENT_SKILLS_UPSTREAM_DIR:-$HOME/dev/code/agent-skills}
mpskills=${MP_SKILLS_UPSTREAM_DIR:-$HOME/dev/code/mattpocock-skills}

# Sources: UPSTREAM.md Baseline name | clone | folder in the clone | source prefix in rows |
# manifest with the version | list upstream files no row covers (1) or only the taken rows (0).
sources_tbl="pstack|$plugins|pstack||.cursor-plugin/plugin.json|0
agent-skills|$agentskills|.|as:|.claude-plugin/plugin.json|1
mattpocock-skills|$mpskills|.|mp:|.claude-plugin/plugin.json|0"

# item|source|relation|commit for every row, then every graft (relation "graft").
rows=$(awk -F'|' '/^## /{sec=$0}
  NF>=9 && $3 ~ /^ (skill|command|agent|script|reference|doc|eval) $/ {
    for (i=2; i<=7; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $4 "|" $5 "|" $7}
  sec == "## Grafts" && NF==6 && $2 !~ /^ ?(pickle item|---) ?$/ {
    for (i=2; i<=5; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $4 "|graft|" $5}' UPSTREAM.md)

while IFS='|' read -r name repo dir prefix manifest whole; do
  if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    url=https://github.com/cursor/plugins.git
    [ "$name" = agent-skills ] && url=https://github.com/addyosmani/agent-skills.git
    [ "$name" = mattpocock-skills ] && url=https://github.com/mattpocock/skills.git
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
  echo "## Changed rows and grafts"
  sources=""
  while IFS='|' read -r item src rel from; do
    [ "$src" = "-" ] && continue
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
    for p in "${paths[@]}"; do
      g cat-file -e "$from:$p" 2>/dev/null || echo "upstream-diff: $item ($rel): $p is not in $name at $from" >&2
    done
    stat=$(g diff --stat "$from" "$new" -- "${paths[@]}")
    [ -n "$stat" ] || continue
    echo
    echo "### $item ($rel) <- $src since ${from:0:7}"
    if [ "$full" = 1 ]; then g diff "$from" "$new" -- "${paths[@]}"; else echo "$stat"; fi
  done <<< "$rows"

  # agent-skills is tracked as a whole. For pstack and mattpocock-skills, only the rows pickle took.
  if [ "$whole" = 1 ]; then
    echo
    echo "## Upstream files no row covers"
    g diff --name-only --diff-filter=A "$base" "$new" -- "${pre}skills" "${pre}agents" "${pre}.claude/commands" | while read -r f; do
      c=0
      for s in $sources; do case "$f" in "$s"|"$s"/*) c=1; break;; esac; done
      [ "$c" = 1 ] || echo "$f"
    done
  fi
  echo
done <<< "$sources_tbl"

echo "Per row or graft: take, ignore or note the change and set its Commit (and a row's Upstream version) to the upstream one, then that source's Baseline when all its rows are done."
