---
name: why
description: Finds why code is shaped the way it is, from git history, PRs, issues, docs and any MCP sources in the session, as a cited, confidence-tiered answer. Use for "why does X work this way", "why did we pick Y", regressions, postmortems and where a threshold came from.
argument-hint: "[code, decision or question]"
metadata:
  upstream: pstack/skills/why
  upstream-version: 0.15.25
---

# Why

Investigate the motivation and intent behind code: what forces led to its shape. For what the code does and how it runs, use the **how** skill (Skill tool, `pickle:how`).

Work as a careful, cautious and precise investigator. Be honest about what you know and what you infer. The confidence tiers and phrasing rules are in `${CLAUDE_SKILL_DIR}/references/epistemics.md`. Read it before you write the answer, or pass its path to the synthesizer.

## Subagents

- Spawn every subagent with the Agent tool, `subagent_type: "general-purpose"`. It can run `git` and `gh` and call MCP tools. Leave `model` unset.
- Set `run_in_background: false` on every Agent call. Send all investigators in one message so they run at the same time.
- Investigators and the synthesizer only read. Each prompt says: do not edit files, commit, or change anything outside the session.
- If the Agent tool is not available (for example, inside a subagent at the nesting limit), do each step yourself in order.

## Step 1. Understand the target and the question

The **target** is usually a chunk of code, a pattern, a feature or a named design decision. The **question** is usually a design rationale, a trade-off, a motivating edge case, an external constraint, dead code or a broad history sweep.

If the target is vague ("why do we do it this way?" with no clear referent), make your best guess from the conversation: open files, recent edits, what was just discussed. State your reading in one line so the user can redirect, then go on.

## Step 2. Build the code anchor

Before any investigation, collect the seed context yourself:

```bash
git blame -L <start>,<end> <file>          # last-touch commits
git log --follow -p -- <file>              # full history through renames
git log --oneline -20 -- <file>            # recent commits, PR numbers visible
git log -1 --format=%B <commit>            # PR number from a merge commit
gh pr view <number> --json title,body,author,createdAt,mergedAt,labels,closingIssuesReferences,comments,reviews
```

The anchor is: file paths and line ranges, key symbols, the last few commits touching the target, PR numbers (pattern `(#1234)` in the subject line), the PR bodies and discussion for each substantive commit, and any linked ticket IDs. Every investigator and the synthesizer get it.

## Step 3. Find the evidence sources

Source control history (git and `gh`) is always available. For the other six categories, look for MCP tools in this session. Their names start with `mcp__<server>__`. Most are deferred: the name is listed, and the schema loads through ToolSearch. If no list is visible, search ToolSearch by keyword for each category.

Map each MCP server to one category, by its name, server instructions and tool names. If one could fit two, pick its primary evidence and record the call in Sources Consulted. If a server needs authentication and fails, record the category as a gap.

| Category | Best at | Source guide (example server) |
|---|---|---|
| Source control history | rationale captured in review | `references/sources/source-control.md` (git, `gh`) |
| Issue / ticket tracker | the product or business forcing function | `references/sources/issue-tracker.md` (Linear, Jira, GitHub Issues) |
| Long-form documents | design rationale written before the code | `references/sources/docs.md` (Notion, Confluence, Google Docs) |
| Real-time team chat | deliberation that never reached a doc | `references/sources/chat.md` (Slack, Teams, Discord) |
| Infrastructure observability | runtime signals that motivated the code: timeouts, retries, rate limits | `references/sources/observability.md` (Datadog, Grafana, Honeycomb) |
| Error / exception tracking | the exceptions behind defensive code | `references/sources/error-tracking.md` (Sentry, Rollbar, Bugsnag) |
| Product analytics warehouse | product data behind flags, experiments and thresholds | `references/sources/analytics-warehouse.md` (Databricks, Snowflake, BigQuery) |

The guides name the example server's tools. Other servers in the same category have their own tool names: adapt.

## Step 4. Investigate

**Only source control history is available.** Skip the subagents. Run the source-control guide yourself, then go to Step 5 and write the answer yourself.

**Two or more categories are available.** Spawn one investigator per available category, each owning exactly one source. Never give one investigator two sources. Each prompt is `references/investigator-prompt.md` filled in, plus:

- the source guide for its category, with the MCP server's name so the investigator can load its tools through ToolSearch
- `references/sources/incident.md` if the target looks defensive: null checks, retries, timeouts, rate limits, feature flags, egress guards, out-of-memory handlers
- the code anchor and the user's question, word for word

Skip an available category only when it is provably irrelevant, not probably: "Error / exception tracking skipped. The target is a build script with no runtime path." Write the reason down for Sources Consulted.

## Step 5. Synthesize

With investigators: spawn one synthesizer. Its prompt is `references/synthesizer-prompt.md` filled in with every investigator's findings (null results included), the skipped categories and their reasons, the code anchor, the user's question, and the path `${CLAUDE_SKILL_DIR}/references/epistemics.md` to read in full.

Without investigators: follow `references/synthesizer-prompt.md` and `references/epistemics.md` yourself.

## Step 6. Present

Present the answer. You may lightly edit it for clarity or add context from the conversation. **Do not rewrite the confidence language.** If the project has a `GLOSSARY.md` (or a `GLOSSARY-MAP.md`), use its terms for domain concepts.

The structure is the one in `references/synthesizer-prompt.md`: The Question, The Code in Question, What We Found, What We Can Reasonably Infer, Competing Hypotheses, What We Don't Know, Sources Consulted, Confidence Summary. Keep Sources Consulted to one line per category, including the ones that were unavailable, skipped or empty, each with its reason.

If the question comes before a change to this code, end with the findings as constraints for the change: Preserve, Change, Avoid, Risk.

## Failure modes

- **Recency bias.** The latest commit is not the whole story. The current shape is often many earlier decisions stacked up. Trace back.
- **Confirming the user's guess.** A hypothesis in the question is one candidate. Check it like any other.
- **Code as its own evidence.** What the code does is not why it exists.
