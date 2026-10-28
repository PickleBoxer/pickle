#!/usr/bin/env bash
# Fails when a skill or agent mention does not resolve, when a called
# skill is user-only, when pickle-mode names a skill bare, when an extension calls a skill, or when
# UPSTREAM.md disagrees with the files: rows, grafted sections, and vendored Notes against the
# vendor/agent-skills branch.
# Run from anywhere: bash scripts/check-refs.sh
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
err() { echo "check-refs: $*"; fail=1; }

SKILL_KEYS=" name description when_to_use argument-hint arguments disable-model-invocation user-invocable allowed-tools disallowed-tools model effort context agent background hooks paths shell metadata license compatibility "
AGENT_KEYS=" name description tools disallowedTools model effort maxTurns skills memory background isolation color omitClaudeMd experimental "

# Frontmatter of a file: the lines between the first two --- lines.
fm() { awk '/^---$/{n++; next} n==1' "$1"; }
fm_key() { fm "$1" | awk -v k="$2" -F': *' '$1==k {sub(/^[^:]*: */, ""); gsub(/^"|"$/, ""); print; exit}'; }
fm_meta() { fm "$1" | awk -v k="$2" '/^metadata:/{m=1; next} m && /^[^ ]/{m=0} m {sub(/^ +/, ""); split($0, a, /: */); if (a[1]==k) {sub(/^[^:]*: */, ""); print; exit}}'; }
user_only() { [ "$(fm_key "skills/$1/SKILL.md" disable-model-invocation)" = "true" ]; }

shipped=$(find skills agents commands references -name '*.md' -type f 2>/dev/null | sort; ls README.md GLOSSARY.md 2>/dev/null)

# Frontmatter keys
for f in skills/*/SKILL.md commands/*.md; do
  [ -e "$f" ] || continue
  for k in $(fm "$f" | grep -oE '^[A-Za-z_-]+:' | tr -d ':'); do
    case "$SKILL_KEYS" in *" $k "*) ;; *) err "$f: unknown skill frontmatter key '$k'";; esac
  done
done
for f in agents/*.md; do
  for k in $(fm "$f" | grep -oE '^[A-Za-z_-]+:' | tr -d ':'); do
    case "$AGENT_KEYS" in *" $k "*) ;; *) err "$f: agent frontmatter key '$k' is unknown or ignored for plugin agents";; esac
  done
done

# /pickle:<skill>: the user runs it, or prose names it. Must exist.
while IFS=: read -r f l m; do
  n=${m#/pickle:}
  [ -f "skills/$n/SKILL.md" ] || [ -f "commands/$n.md" ] || err "$f:$l: /pickle:$n has no skills/$n/SKILL.md or commands/$n.md"
done < <(grep -noE '/pickle:[a-z0-9-]+' $shipped)

# pickle:<name> without a slash: the agent calls a skill (Skill tool) or an agent (subagent_type).
while IFS=: read -r f l m; do
  n=${m##*pickle:}
  if [ -f "skills/$n/SKILL.md" ]; then
    user_only "$n" && err "$f:$l: pickle:$n is called, but skills/$n is disable-model-invocation"
  elif [ ! -f "agents/$n.md" ]; then
    err "$f:$l: pickle:$n is neither skills/$n nor agents/$n.md"
  fi
done < <(grep -noE '(^|[^/[:alnum:]-])pickle:[a-z0-9-]+' $shipped)

# the **name** skill (Skill tool, `pickle:name`): a skill the agent calls. The pickle:name part is
# checked above (exists, model-invocable). Here: the bold name matches it.
while IFS=: read -r f l m; do
  a=$(echo "$m" | sed -E 's/^\*\*([a-z0-9-]+)\*\*.*/\1/'); b=${m##*pickle:}; b=${b%\`)}
  [ "$a" = "$b" ] || err "$f:$l: **$a** skill points at pickle:$b"
done < <(grep -noE '\*\*[a-z0-9-]+\*\* skill \(Skill tool, `pickle:[a-z0-9-]+`\)' $shipped)

# Old mention form, replaced because /pickle:name reads as a command for the user.
while IFS=: read -r f l m; do
  err "$f:$l: $m is the old form, write: the **name** skill (Skill tool, \`pickle:name\`)"
done < <(grep -noE '\*\*[a-z0-9-]+\*\* \(/pickle:[a-z0-9-]+\)' $shipped)

# Relative Markdown links in skill, reference and doc files, and `references/...` paths in skill
# files, resolve from the linking file. ${CLAUDE_PLUGIN_ROOT}/ paths anywhere resolve from the repo
# root (anchors ignored).
while IFS= read -r f; do
  re='\]\([^) ]+\)'; case "$f" in skills/*) re="$re|\`references/[^\` ]+\`";; esac
  while IFS=: read -r l t; do
    t=${t#](}; t=${t%)}; t=${t#\`}; t=${t%\`}; t=${t%%#*}
    case "$t" in ""|*://*|mailto:*|'${CLAUDE_PLUGIN_ROOT}/'*) continue;; esac
    [ -e "$(dirname "$f")/$t" ] || err "$f:$l: link $t does not resolve"
  done < <(grep -noE "$re" "$f")
done < <(find skills references docs -name '*.md' -type f 2>/dev/null)
while IFS=: read -r f l t; do
  t=${t#'${CLAUDE_PLUGIN_ROOT}/'}; t=${t%%#*}
  [ -e "$t" ] || err "$f:$l: \${CLAUDE_PLUGIN_ROOT}/$t does not resolve"
done < <(grep -noE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+[A-Za-z0-9_-]' $shipped)

# pickle-mode routes by name: every workflow skill in it must be a checked call, never bare.
# Upstream writes bare names, so a merge can bring one in. Drop the call forms, then look for leftovers.
# One-word names (how, why) are also English words, so they count only in code font or bold.
pm=skills/pickle-mode/SKILL.md
names=$(ls skills | grep -vx pickle-mode | grep -- - | paste -sd'|' -)
words=$(ls skills | grep -vx pickle-mode | grep -v -- - | paste -sd'|' -)
while IFS=: read -r l t; do
  t=$(echo "$t" | tr -d '`*')
  err "$pm:$l: bare skill name '$t', write: the **$t** skill (Skill tool, \`pickle:$t\`)"
done < <(sed -E 's/\*\*[a-z0-9-]+\*\* skill \(Skill tool, `pickle:[a-z0-9-]+`\)//g; s/pickle:[a-z0-9-]+//g' "$pm" \
  | grep -noE "(^|[^a-z0-9-])($names)([^a-z0-9-]|\$)|\`($words)\`|\*\*($words)\*\*" | sed -E 's/:[^a-z`*]*/:/; s/[^a-z0-9`*-]*$//')

# Extensions are called by workflow skills and call nothing themselves, so dependencies point one way:
# pickle-mode, then workflow skills, then extensions.
for x in codebase-design domain-modeling; do
  [ -d "skills/$x" ] || { err "skills/$x: extension is missing"; continue; }
  [ "$(fm_key "skills/$x/SKILL.md" user-invocable)" = "false" ] || err "skills/$x/SKILL.md: extension needs user-invocable: false"
  while IFS=: read -r f l m; do
    err "$f:$l: extension $x calls ${m##*[^a-z0-9:-]}, but extensions call no skill"
  done < <(grep -rnoE '(^|[^/[:alnum:]-])pickle:[a-z0-9-]+' "skills/$x")
done

# Agent skills: preload lists. A user-only skill there is skipped silently.
for f in agents/*.md; do
  for s in $(fm "$f" | awk '/^skills:/{m=1; sub(/^skills: */, ""); gsub(/[][,]/, " "); print; next} m && /^ *- /{sub(/^ *- */, ""); print; next} m{m=0}'); do
    n=${s#pickle:}
    [ -f "skills/$n/SKILL.md" ] || { err "$f: skills: $s has no skills/$n/SKILL.md"; continue; }
    user_only "$n" && err "$f: skills: $s is disable-model-invocation and would be skipped silently"
  done
done

# UPSTREAM.md rows: item | kind | source | relation | version | commit | notes
rows=$(awk -F'|' 'NF>=9 && $3 ~ /^ (skill|command|agent|reference|doc|eval|script) $/ {
  for (i=2; i<=8; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8}' UPSTREAM.md)
[ -n "$rows" ] || err "UPSTREAM.md: no rows found"
# agent-skills syncs as one: every vendored row has the Baseline version and commit.
as_ver=$(awk -F'|' '$2 == " agent-skills " {gsub(/ /, "", $4); print $4}' UPSTREAM.md)
as_sha=$(awk -F'|' '$2 == " agent-skills " {gsub(/ /, "", $5); print $5}' UPSTREAM.md)
# Vendored Notes are checked against the vendor branch, once main has merged it. CI fetches it.
vref=""
for r in refs/heads/vendor/agent-skills refs/remotes/origin/vendor/agent-skills; do
  git rev-parse -q --verify "$r" >/dev/null && { vref=$r; break; }
done
if [ -z "$vref" ]; then
  err "no vendor/agent-skills branch to check vendored Notes against. Run: git fetch origin vendor/agent-skills:vendor/agent-skills"
elif ! git merge-base --is-ancestor "$vref" HEAD; then
  err "$vref has commits HEAD has not merged. Merge it before checking UPSTREAM.md"
  vref=""
fi

while IFS='|' read -r item kind src rel ver sha notes; do
  case "$rel" in ported|rewritten|vendored|new) ;; *) err "UPSTREAM.md: $item: unknown relation '$rel'";; esac
  [ -e "$item" ] || { err "UPSTREAM.md: $item does not exist"; continue; }
  if [ "$rel" = "new" ]; then
    [ "$sha" = "-" ] || err "UPSTREAM.md: $item is new, so its Commit is -, not '$sha'"
  else
    [[ "$sha" =~ ^[0-9a-f]{7,40}$ ]] || err "UPSTREAM.md: $item: Commit '$sha' is not a commit"
  fi
  if [ "$rel" = "vendored" ]; then
    case "$src" in as:*) ;; *) err "UPSTREAM.md: $item is vendored, but only as: sources sync";; esac
    [ "$ver" = "$as_ver" ] || err "UPSTREAM.md: $item is vendored at $ver, agent-skills Baseline is $as_ver"
    [ "$sha" = "$as_sha" ] || err "UPSTREAM.md: $item is vendored at $sha, agent-skills Baseline is $as_sha"
    if [ -n "$vref" ]; then
      on_main=0; case "$notes" in *'on `main`'*|*'On `main`'*) on_main=1;; esac
      if git diff --quiet "$vref" -- "$item"; then
        [ "$on_main" = 0 ] || err "UPSTREAM.md: $item Notes say on \`main\`, but it matches $vref"
      else
        [ "$on_main" = 1 ] || err "UPSTREAM.md: $item differs from $vref, but its Notes do not say what changed on \`main\`"
      fi
    fi
  fi
  if [ "$kind" = "skill" ]; then
    sk=$item; [ -d "$sk" ] && sk="$sk/SKILL.md"
    up=$(fm_meta "$sk" upstream); upv=$(fm_meta "$sk" upstream-version)
    if [ "$rel" = "new" ]; then
      [ -z "$up" ] || err "$sk: metadata upstream '$up' on a new skill"
    else
      case "$src" in as:*) exp="agent-skills/${src#as:}";; mp:*) exp="mattpocock-skills/${src#mp:}";; *) exp="pstack/$src";; esac
      [ "$up" = "$exp" ] || err "$sk: metadata upstream '$up', UPSTREAM.md says '$exp'"
      [ "$upv" = "$ver" ] || err "$sk: metadata upstream-version '$upv', UPSTREAM.md says '$ver'"
    fi
  fi
done <<< "$rows"

# Every shipped skill, agent and command has a row.
items=$(echo "$rows" | cut -d'|' -f1)
has_row() { echo "$items" | grep -qxF "$1"; }

# Grafts: item | sections | source | commit. Each section is a heading in the item, and the item
# sits under a row.
while IFS='|' read -r item sections src sha; do
  [ -f "$item" ] || { err "UPSTREAM.md: graft $item does not exist"; continue; }
  covered=0
  for i in $items; do case "$item" in "$i"|"$i"/*) covered=1; break;; esac; done
  [ "$covered" = 1 ] || err "UPSTREAM.md: graft $item is under no row"
  [ -n "$src" ] && [ "$src" != "-" ] || err "UPSTREAM.md: graft $item has no source"
  [[ "$sha" =~ ^[0-9a-f]{7,40}$ ]] || err "UPSTREAM.md: graft $item: Commit '$sha' is not a commit"
  IFS=';' read -ra secs <<< "$sections"
  for sec in "${secs[@]}"; do
    sec=$(echo "$sec" | sed -E 's/^ +| +$//g')
    grep -qxE "#+ $(printf '%s' "$sec" | sed 's/[][\\.*^$()+?{}|]/\\&/g')" "$item" \
      || err "UPSTREAM.md: graft $item: no heading '$sec'"
  done
done < <(awk -F'|' '/^## /{sec=$0} sec == "## Grafts" && NF==6 && $2 !~ /^ ?(pickle item|---) ?$/ {
  for (i=2; i<=5; i++) {gsub(/^ +| +$/, "", $i)} print $2 "|" $3 "|" $4 "|" $5}' UPSTREAM.md)
for f in skills/*/SKILL.md; do
  d=${f%/SKILL.md}
  has_row "$d" || has_row "$f" || err "$f: no UPSTREAM.md row"
done
for f in agents/*.md commands/*.md; do
  [ -e "$f" ] || continue
  has_row "$f" || err "$f: no UPSTREAM.md row"
done

[ "$fail" = 0 ] && echo "check-refs: ok"
exit "$fail"
