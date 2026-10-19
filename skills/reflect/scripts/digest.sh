#!/usr/bin/env bash
# Prints a Markdown digest of Claude Code session transcripts, for the reflect skill.
#
#   digest.sh <current-session-id> [target]
#
# target: empty (the current session), a session ID, a path to a .jsonl transcript, or "last N"
# (the N most recent sessions of this project, the current one included). Session IDs resolve only
# inside the current session's project folder, so the digest never reads another project's chats.
#
# The digest has the counts and signals a script can find without judgment (failed calls, repeated
# commands, files read more than once, the largest tool results, skills and subagents used), then a
# timeline with every user prompt and one line per tool call.
set -euo pipefail

root="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
self=${1:?usage: digest.sh <current-session-id> [target]}
shift
target="$*"

die() { echo "digest.sh: $*" >&2; exit 1; }

self_file=$(find "$root" -mindepth 2 -maxdepth 2 -name "$self.jsonl" 2>/dev/null | head -1)
project=${self_file%/*}

case "$target" in
  "") [ -n "$self_file" ] || die "no transcript for session $self under $root"; files=("$self_file") ;;
  *.jsonl) [ -f "$target" ] || die "no file $target"; files=("$target") ;;
  "last "*)
    n=${target#last }; [[ "$n" =~ ^[0-9]+$ ]] || die "expected: last <number>"
    [ -n "$project" ] || die "no transcript for session $self under $root"
    files=(); while IFS= read -r f; do files+=("$f"); done < <(ls -t "$project"/*.jsonl | head -"$n") ;;
  *)
    [[ "$target" =~ ^[0-9a-f-]{36}$ ]] || die "unknown target '$target': give a session ID, a .jsonl path or 'last N'"
    [ -n "$project" ] && [ -f "$project/$target.jsonl" ] || die "session $target is not in this project's folder"
    files=("$project/$target.jsonl") ;;
esac

digest() {
  jq -rs --arg path "$1" '
    def clip($n): tostring | gsub("\\s+"; " ") | if length > $n then .[0:$n] + "…" else . end;
    def summary: if type == "object"
      then (.command // .file_path // .pattern // .skill // .description // .url // .query // .prompt // tostring)
      else tostring end;
    def text: if type == "string" then . else (map(select(.type == "text") | .text) | join(" ")) end;

    map(select(.type == "user" or .type == "assistant")) as $msgs
    | [$msgs[] | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use")] as $calls
    | (reduce $calls[] as $c ({}; .[$c.id] = $c)) as $by_id
    | [$msgs[] | select(.type == "user") | .message.content | arrays | .[] | select(.type == "tool_result")
       | . as $r | ($by_id[$r.tool_use_id] // {name: "?", input: {}}) as $c
       | {name: $c.name, input: ($c.input | summary), error: ($r.is_error == true),
          size: ($r.content | tostring | length), out: ($r.content | if type == "array" then map(.text? // "") | join(" ") else tostring end)}] as $results
    | [$msgs[] | select(.type == "user" and (.isMeta | not) and (.isCompactSummary | not))
       | select((.message.content | type) == "string" or ([.message.content[]? | select(.type == "tool_result")] | length) == 0)
       | .message.content | text | select(test("^\\s*<(local-command|command-name|system-reminder)") | not)] as $prompts
    | ([$msgs[] | select(.type == "assistant") | {id: .message.id, u: .message.usage}] | unique_by(.id) | map(.u)) as $usage
    | ($msgs | map(select(.version)) | last // {}) as $meta

    | "# Session \($msgs[0].sessionId // "?")",
      "",
      "- Transcript: \($path)",
      "- Claude Code \($meta.version // "?"), branch \($meta.gitBranch // "?"), cwd \($meta.cwd // "?")",
      "- \($prompts | length) user prompts, \($calls | length) tool calls, \([$results[] | select(.error)] | length) failed",
      "- Output tokens \([$usage[].output_tokens // 0] | add // 0), context at the end \(($usage | last // {}) | [.input_tokens, .cache_read_input_tokens, .cache_creation_input_tokens] | map(. // 0) | add)",
      "",
      "## Tool calls by name",
      "",
      ($calls | group_by(.name) | map({n: .[0].name, c: length}) | sort_by(-.c) | .[] | "- \(.n): \(.c)"),
      "",
      "## Failed tool calls",
      "",
      ([$results[] | select(.error)] | if length == 0 then "None." else .[] | "- \(.name) `\(.input | clip(120))`: \(.out | clip(200))" end),
      "",
      "## Repeated commands",
      "",
      ([$calls[] | select(.name == "Bash") | .input.command] | group_by(.) | map(select(length > 1) | {c: .[0], n: length}) | sort_by(-.n)
        | if length == 0 then "None." else .[] | "- \(.n)× `\(.c | clip(160))`" end),
      "",
      "## Files read more than once",
      "",
      ([$calls[] | select(.name == "Read") | .input.file_path] | group_by(.) | map(select(length > 1) | {f: .[0], n: length}) | sort_by(-.n)
        | if length == 0 then "None." else .[] | "- \(.n)× \(.f)" end),
      "",
      "## Largest tool results (characters)",
      "",
      ($results | sort_by(-.size) | .[0:5][] | "- \(.size) \(.name) `\(.input | clip(120))`"),
      "",
      "## Skills and subagents",
      "",
      ([$calls[] | select(.name == "Skill") | "- Skill \(.input.skill)\(if .input.args then " (\(.input.args | clip(80)))" else "" end)"]
        + [$calls[] | select(.name == "Read" and ((.input.file_path // "") | test("SKILL\\.md$"))) | "- Read \(.input.file_path)"]
        + [$calls[] | select(.name == "Agent" or .name == "Task") | "- Agent \(.input.subagent_type // "general-purpose"): \(.input.description // "" | clip(100))"]
        | if length == 0 then "None." else .[] end),
      "",
      "## Timeline",
      "",
      "`U` user prompt, `A` assistant text, `T` tool call, `✗` failed call.",
      "",
      (reduce $msgs[] as $m ({out: [], p: 0};
        if $m.type == "user" then
          if ($m.message.content | type) == "string" or ([$m.message.content[]? | select(.type == "tool_result")] | length) == 0 then
            ($m.message.content | text) as $t
            | if ($m.isMeta or $m.isCompactSummary) or ($t | test("^\\s*<(local-command|command-name|system-reminder)")) then .
              else .p += 1 | .out += ["U\(.p) \($t | clip(400))"] end
          else
            reduce ($m.message.content[] | select(.type == "tool_result" and .is_error == true)) as $r (.;
              .out += ["  ✗ \($r.content | if type == "array" then map(.text? // "") | join(" ") else tostring end | clip(200))"])
          end
        else
          reduce ($m.message.content[]?) as $b (.;
            if $b.type == "text" and ($b.text | length) > 0 then .out += ["  A \($b.text | clip(200))"]
            elif $b.type == "tool_use" then .out += ["  T \($b.name) `\($b.input | summary | clip(140))`"]
            else . end)
        end) | .out[])
  ' "$1"

  local subs="${1%.jsonl}/subagents"
  if [ -d "$subs" ]; then
    echo
    echo "## Subagent transcripts"
    echo
    for s in "$subs"/*.jsonl; do
      [ -e "$s" ] || continue
      local meta="${s%.jsonl}.meta.json" desc=""
      [ -f "$meta" ] && desc=$(jq -r '"\(.agentType // "?"): \(.description // "")"' "$meta")
      jq -rs --arg s "$s" --arg d "$desc" '
        [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use")] as $c
        | [.[] | select(.type == "user") | .message.content | arrays | .[] | select(.type == "tool_result" and .is_error == true)] as $e
        | "- \($d): \($c | length) tool calls, \($e | length) failed. \($s)"' "$s"
    done
  fi
}

for f in "${files[@]}"; do
  digest "$f"
  echo
done
