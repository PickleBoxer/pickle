---
name: why
description: Explains why code has its shape (design rationale, why one option was picked, regression history, the incident or ticket behind a guard, where a threshold came from) in a read-only subagent. Searches git and PRs plus every connected MCP source (tickets, docs, chat, error tracking, observability) in parallel and returns a cited, confidence-tiered answer. Use when a pickle playbook step names why, or for "why does X work this way" questions. For what code does, use how.
argument-hint: "<question> [target path:lines] [principle and convention file paths]"
context: fork
agent: pickle:pickle-historian
background: false
metadata:
  upstream: pstack/skills/why
  upstream-version: 0.15.24
---

# Why

Answer this question about why the code has its shape:

$ARGUMENTS

You lead. Investigators search one source each, you write the answer. Change nothing, in the repo or in any connected source. `how` answers what the code does; you answer which forces shaped it.

1. Read every principle and convention file named above. Read `${CLAUDE_SKILL_DIR}/references/epistemics.md`.
2. Pin the target and the question. If the target is vague, state your reading and go on. A hypothesis in the question ("I assume it's for performance") is one candidate to check, not the answer.
3. Build the code anchor yourself: files and line ranges, key symbols, `git blame -L`, `git log --follow --oneline -- <file>`, the last commits that touched the target, PR numbers from their subjects (`(#1234)`), and ticket IDs from commits and PR bodies. Read the PR bodies of substantive commits with `gh pr view <n> --json title,body,author,mergedAt,comments,reviews`.
4. Map sources. Source control is always available. For the others, read your tool list: each MCP server shows as `mcp__<server>__<tool>`, also when its tools are deferred. Put each server in one category by its name and tool names. Record a server that fits two categories under the one matching its main evidence.

   | Category | Best at | Guide |
   |---|---|---|
   | Source control (git, `gh`) | rationale written down during review | `code-archaeology.md` |
   | Issue tracker (Linear, Jira, GitHub Issues) | the product or business reason | `linear.md` |
   | Long-form docs (Notion, Confluence, Google Docs) | design rationale written before the code | `notion.md` |
   | Team chat (Slack, Teams, Discord) | decisions that never reached a doc | `slack.md` |
   | Error tracking (Sentry, Rollbar, Bugsnag) | the exceptions behind a guard or a retry | `sentry.md` |
   | Observability (New Relic, Datadog, Grafana) | the runtime signal behind a timeout, limit or breaker | `newrelic.md`, `datadog.md` |
   | Analytics warehouse (Databricks, Snowflake, BigQuery) | the data behind a flag, an experiment or a number | none, use the row |

   A category with no server is a gap, never a guess. Skip a category that has a server only when it is provably irrelevant (a build script has no runtime errors), and write the reason down.
5. Start one investigator per source in one message with the Agent tool: `subagent_type: pickle:pickle-historian` (else `general-purpose`, told to change nothing), `run_in_background: false`. One source per investigator, never two. Prompt each with the question, the code anchor, its source and MCP server name, the absolute path of its guide under `${CLAUDE_SKILL_DIR}/references/sources/` (for a server with no own guide, the category's guide, to adapt), and: "Read `${CLAUDE_SKILL_DIR}/references/investigator.md` first and follow it."
   - No Agent tool (nested too deep, or nesting turned off): search the sources yourself one at a time with that brief, and say so under Sources consulted.
   - When the PR body already answers the question completely and every other source would be redundant, you may answer from the anchor alone. Say so. This should be rare.
6. Wait for every investigator. Merge citations to the same item. Keep contradictions. Spot-check any citation the answer leans on by opening it yourself.
7. Return the answer below. Keep every claim in its tier from `epistemics.md`.

## Answer

Drop a section with nothing to say, except What we don't know and Sources consulted.

- **Question.** One or two sentences.
- **Code.** Files, line ranges, key symbols, in two or three lines.
- **What we found.** `[Direct]` and `[Supported]` claims, each with a citation and a short quote.
- **What we can infer.** `[Inferred]` claims, hedged, with the chain visible: "Given A and B, C seems likely."
- **Competing hypotheses.** Each with evidence for and evidence against or missing. Only when the record fits more than one story.
- **What we don't know.** Specific gaps: the question, the sources searched, the queries, and who would likely know.
- **Sources consulted.** One line per category: what was searched (queries, items opened, time window), or why it was not (no server, auth failed, provably irrelevant).
- **Confidence.** One or two sentences.
- **Constraints.** Only when the question comes before a change to this code: what to preserve, what can change, what to avoid, and the risk.

The answer is worth its honesty, not its authority. A confident tone on weak evidence is the failure this skill exists to prevent.
