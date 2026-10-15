#!/usr/bin/env bash
# Maintainer only. Refreshes the vendor/agent-skills branch from addyosmani/agent-skills: every
# `vendored` row with an `as:` source in UPSTREAM.md (skills, commands, agents), copied to its
# pickle path. Shared root references are copied into each skill that links them, long dashes
# are replaced, metadata.upstream is added to skills, and names and paths are rewritten for
# pickle: agent-skills:<x> and the vendored /command and `agent` names become pickle:<x>, and
# repo-relative paths in commands and agents become ${CLAUDE_PLUGIN_ROOT} paths. Stages the result in a worktree of the vendor branch and prints the
# commit and merge commands. Commits nothing, touches no other branch.
#
# Usage: bash scripts/vendor-sync.sh [ref]     ref defaults to upstream origin/HEAD
# Env:   AGENT_SKILLS_UPSTREAM_DIR, a clone of https://github.com/addyosmani/agent-skills
#        (default ~/dev/code/agent-skills)
#        VENDOR_WORKTREE, where the vendor branch is checked out
#        (default $TMPDIR/pickle-vendor-agent-skills)
set -euo pipefail
cd "$(dirname "$0")/.."

branch=vendor/agent-skills
repo=${AGENT_SKILLS_UPSTREAM_DIR:-$HOME/dev/code/agent-skills}
tmp=${TMPDIR:-/tmp}
wt=${VENDOR_WORKTREE:-${tmp%/}/pickle-vendor-agent-skills}
wt=${wt%/}

if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  echo "vendor-sync: no agent-skills clone at $repo. Clone it once:" >&2
  echo "  git clone --filter=blob:none https://github.com/addyosmani/agent-skills.git $repo" >&2
  exit 1
fi
g() { git -C "$repo" "$@"; }

g fetch -q --tags origin
sha=$(g rev-parse "${1:-origin/HEAD}^{commit}")
version=$(g show "$sha:.claude-plugin/plugin.json" | sed -nE 's/.*"version": *"([^"]+)".*/\1/p')
[ -n "$version" ] || { echo "vendor-sync: no version in .claude-plugin/plugin.json at $sha" >&2; exit 1; }

# item|source for every vendored as: row
rows=$(awk -F'|' 'NF>=8 {for (i=2; i<=6; i++) gsub(/^ +| +$/, "", $i)}
  NF>=8 && $5 == "vendored" && $4 ~ /^as:/ {sub(/^as:/, "", $4); print $2 "|" $4}' UPSTREAM.md)
[ -n "$rows" ] || { echo "vendor-sync: no vendored as: rows in UPSTREAM.md" >&2; exit 1; }

# Vendor branch worktree: reuse, check out, or start the orphan branch. Prune first: macOS
# clears $TMPDIR, which leaves a stale worktree entry that blocks `worktree add`.
git worktree prune
if [ -d "$wt" ]; then
  [ "$(git -C "$wt" branch --show-current 2>/dev/null)" = "$branch" ] \
    || { echo "vendor-sync: $wt exists and is not a $branch worktree" >&2; exit 1; }
  [ -z "$(git -C "$wt" status --porcelain)" ] \
    || { echo "vendor-sync: $wt has uncommitted changes. Commit or discard them first" >&2; exit 1; }
elif git rev-parse -q --verify "refs/heads/$branch" >/dev/null; then
  git worktree add -q "$wt" "$branch"
else
  git worktree add -q --detach "$wt"
  git -C "$wt" checkout -q --orphan "$branch"
fi
git -C "$wt" rm -rq --cached --ignore-unmatch . >/dev/null
find "$wt" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +

src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT
g archive "$sha" | tar -x -C "$src"

# Long dashes out (pickle CI rejects them): "**term** -- text" and "`term` -- text" take a
# colon, other spaced dashes a comma, en dashes a hyphen. Then root reference links point at
# the skill's own references/ folder.
fix() {
  perl -CSD -i -pe '
    s/\|\s*\x{2014}\s*\|/| - |/g;
    s/(\*\*|`)\s+\x{2014}\s+/$1: /g;
    s/\s+\x{2014}\s+/, /g;
    s/\x{2014}/, /g;
    s/\x{2013}/-/g;
    s{(?:\.\./){3}references/}{}g if $ARGV =~ m{/references/[^/]+$};
    s{(?:\.\./){2}references/}{references/}g;
  ' "$1"
}

while IFS='|' read -r item path; do
  [ -e "$src/$path" ] || { echo "vendor-sync: $path does not exist upstream at ${sha:0:7}" >&2; exit 1; }
  mkdir -p "$wt/$(dirname "$item")"
  cp -R "$src/$path" "$wt/$item"
  if [ -d "$wt/$item" ]; then
    # Shared root references this skill links, from any of its files
    for r in $(grep -rhoE '(\.\./){2,3}references/[a-z0-9-]+\.md' "$wt/$item" | sed 's#.*/##' | sort -u); do
      mkdir -p "$wt/$item/references"
      cp "$src/references/$r" "$wt/$item/references/$r"
    done
    cp "$src/LICENSE" "$wt/$item/LICENSE"
    find "$wt/$item" -name '*.md' -type f | while read -r f; do fix "$f"; done
    sk="$wt/$item/SKILL.md"
    if [ -f "$sk" ]; then
      awk '/^---$/{n++} n<2 && /^metadata:/{f=1} END{exit !f}' "$sk" \
        && { echo "vendor-sync: $path/SKILL.md has its own metadata now, update this script" >&2; exit 1; }
      awk -v up="agent-skills/$path" -v v="$version" '
        /^---$/ {n++; if (n == 2) print "metadata:\n  upstream: " up "\n  upstream-version: " v}
        {print}' "$sk" > "$sk.tmp" && mv "$sk.tmp" "$sk"
    fi
  else
    case "$item" in *.md) fix "$wt/$item";; esac
  fi
done <<< "$rows"

# Commands and agents have no folder for a LICENSE, so one copy covers them.
if echo "$rows" | grep -qE '^(commands|agents)/'; then
  mkdir -p "$wt/LICENSES"
  cp "$src/LICENSE" "$wt/LICENSES/agent-skills.txt"
fi

# Names pickle now ships: vendored commands and agents, as regex alternations.
vnames() { echo "$rows" | cut -d'|' -f1 | sed -nE "s#^$1/([a-z0-9-]+)\.md\$#\1#p" | paste -sd'|' -; }
export VCMDS=$(vnames commands) VAGENTS=$(vnames agents)
# Root reference name=the first skill copy of it, for commands and agents to point at.
REFMAP=""
for r in $(ls "$src/references"); do
  own=$(cd "$wt" && ls skills/*/references/"$r" 2>/dev/null | head -1 || true)
  [ -z "$own" ] || REFMAP="$REFMAP $r=$own"
done
export REFMAP
find "$wt" -name '*.md' -type f ! -path '*/.git/*' | while read -r f; do
  perl -CSD -i -pe '
    BEGIN { %ref = map { split /=/ } grep { length } split / /, $ENV{REFMAP}; $c = $ENV{VCMDS}; $ag = $ENV{VAGENTS} }
    s/\bagent-skills:([a-z0-9-]+)/pickle:$1/g;
    s{(?<![\w./:-])/($c)(?![\w-])}{/pickle:$1}g if length $c;
    s/`($ag)`/`pickle:$1`/g if length $ag;
    s{(?<![\w./\}-])skills/([a-z0-9-]+)/SKILL\.md}{\$\{CLAUDE_PLUGIN_ROOT\}/skills/$1/SKILL.md}g;
    s{(?<![\w./\}-])references/([a-z0-9-]+\.md)}{exists $ref{$1} ? "\$\{CLAUDE_PLUGIN_ROOT\}/$ref{$1}" : "references/$1"}ge
      if $ARGV !~ m{/skills/};
  ' "$f"
done

git -C "$wt" add -A

# Upstream commands (/name) and agents pickle does not ship, still mentioned in the vendored
# files on main. Customize these mentions away, or vendor them; the list shrinks as you do.
echo "Upstream-only commands and agents still mentioned on main:"
cmds=$(g ls-tree --name-only "$sha" .claude/commands/ | sed -E 's#.*/##; s#\.md$##' | tr '\n' ' ')
agents=$(g ls-tree --name-only "$sha" agents/ | sed -E 's#.*/##; s#\.md$##' | tr '\n' ' ')
items=$(echo "$rows" | cut -d'|' -f1)
for n in $cmds $agents; do
  case "|$VCMDS|$VAGENTS|" in *"|$n|"*) continue;; esac
  case " $cmds " in *" $n "*) re="(^|[^a-zA-Z0-9_./:-])/$n([^a-z-]|\$)";; *) re="(^|[^a-z:-])$n([^a-z-]|\$)";; esac
  hits=$(for i in $items; do [ -e "$i" ] && grep -rlE "$re" "$i" || true; done | sed -E 's#^skills/([^/]+)/.*#\1#' | sort -u | tr '\n' ' ')
  [ -z "$hits" ] || echo "  $n: $hits"
done
echo
if git -C "$wt" diff --cached --quiet; then
  echo "vendor-sync: $branch already matches agent-skills $version (${sha:0:7}). Nothing to commit."
  exit 0
fi

git -C "$wt" diff --cached --stat | tail -1

first=""; git rev-parse -q --verify "refs/heads/$branch" >/dev/null || first=" --allow-unrelated-histories"
cat <<EOF

Staged agent-skills $version (${sha:0:7}) on $branch in $wt. Next:

  git -C $wt commit -m "chore(vendor): sync agent-skills $version" -m "Upstream: addyosmani/agent-skills@${sha:0:7}"
  git merge$first --no-ff $branch
  # resolve conflicts, keep your customizations, then set the agent-skills Baseline row in
  # UPSTREAM.md to $version | ${sha:0:7} and every vendored row's Upstream version to $version
  bash scripts/check-refs.sh
EOF
