# Upstream

Where each pickle file comes from upstream (agent-skills, pstack for `typescript-best-practices`, `unslop`, `technical-writing`, `how`, `why` and `reflect`, and mattpocock-skills for `codebase-design`, `domain-modeling`, `setup` and `improve-codebase-architecture`), and the upstream version it was last compared against. The only place pickle records upstream versions. `scripts/check-refs.sh` checks this table against the files, and `scripts/upstream-diff.sh` lists what changed upstream since the baseline. `scripts/vendor-sync.sh` refreshes the `vendored` rows.

## Contents

- Baseline
- Relations
- Skills
- Matt Pocock skills
- Agent skills
- Scripts

## Baseline

| Source | Repo | Version | Commit | Compared |
|---|---|---|---|---|
| pstack | [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) (`pstack/`) | 0.15.25 | 99743e9 | 2026-10-16 |
| agent-skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 0.6.13 | aeac41d | 2026-10-15 |
| mattpocock-skills | [mattpocock/skills](https://github.com/mattpocock/skills) | 1.3.1 | 49dd158 | 2026-10-19 |

## Relations

- `ported`: same text, small fixes.
- `rewritten`: same job, new text.
- `vendored`: upstream text, merged from the `vendor/agent-skills` branch. Local edits stay on `main` and survive each merge. Change a row to `rewritten` to stop syncing it, then keep your copy in the next merge.
- `new`: no upstream source.

A source starting with `as:` is in addyosmani/agent-skills, and one starting with `mp:` is in mattpocock/skills; each version is that repo's. Any other source is in `pstack/` of cursor/plugins.

## Skills

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/typescript-best-practices | skill | skills/typescript-best-practices | ported | 0.15.25 | model-invocable, no `paths` (ignored for plugin skills) |
| skills/unslop | skill | skills/unslop | ported | 0.15.25 | model-invocable (user-only upstream), so other skills can call it. Adds a scope line. Rule numbers kept: other skills cite them |
| skills/technical-writing | skill | skills/technical-writing | ported | 0.15.25 | model-invocable (user-only upstream). Calls `pickle:unslop`, drops the rules unslop already owns, project conventions win, no Cursor house rules |
| skills/how | skill | skills/how | rewritten | 0.15.25 | model-invocable. Claude Code Agent tool (Explore explorers), no per-role models. Simple questions and the explanation are written inline, not by an explainer subagent. Uses `GLOSSARY.md` terms when the project has one |
| skills/why | skill | skills/why | rewritten | 0.15.25 | model-invocable. Claude Code Agent tool and ToolSearch for MCP discovery, no per-role models. Answers inline when only source control is available. Source guides renamed by category, `source-playbook.md` folded into `SKILL.md`, warehouse guide made generic. Uses `GLOSSARY.md` terms when the project has one |
| skills/reflect | skill | skills/reflect | rewritten | 0.15.25 | user-only. Merged with mattpocock-skills `skills/engineering/retro` (1.3.1): its environment categories became the environment lens, and its rule that a mechanical violation gets a check became the deterministic-first criterion. `scripts/digest.sh` finds the transcript from `${CLAUDE_SESSION_ID}`, keeps to this project's folder and prints the deterministic signals. Judgment and divergent lenses merged, tooling lens adds tool economy. Reviewers only above 50 tool calls, synthesis inline, no per-role models. Routings name Claude Code homes (hooks, `.claude/rules/`, auto memory, `/doctor prompt-audit`); larger skill edits go to `skill-creator:skill-creator` |

## Matt Pocock skills

From mattpocock/skills, MIT. `codebase-design` and `domain-modeling` are **extensions**: hidden from the `/` menu (`user-invocable: false`), called by the workflow skills, and calling no other skill (`scripts/check-refs.sh` enforces it). `setup` and `improve-codebase-architecture` are user-only entry points outside the workflow. Reference files moved to `references/`, lowercase. No `agents/openai.yaml` (Codex only).

| pickle item | Kind | mattpocock-skills source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/codebase-design | skill | mp:skills/engineering/codebase-design | ported | 1.3.1 | extension. Description narrowed to internal module shape, not HTTP or public API contracts. Design-it-twice names the Agent tool with `Plan` subagents |
| skills/domain-modeling | skill | mp:skills/engineering/domain-modeling | rewritten | 1.3.1 | extension, glossary only: ADR-FORMAT.md and the ADR rules dropped, since documentation-and-adrs owns ADRs and calls this skill for their terms. Reads `docs/agents/domain.md` when present |
| skills/setup | skill | mp:skills/engineering/setup-matt-pocock-skills | rewritten | 1.3.1 | user-only, `/pickle:setup`. Issue tracker, domain docs and docs sources (`docs/agents/sources.md`, read by source-driven-development); offers `pickle:constraint-driven-development` when there is no `CONSTRAINTS.md`, and keeps the Agent skills block outside a generated block such as Boost's. Otherwise no triage labels, no wayfinder operations, no PR triage flag. Default ADR folder `docs/adr/`. Adds optional glossary seeding through an Explore subagent and `pickle:domain-modeling`. Edits `AGENTS.md` when `CLAUDE.md` only imports it. Adds Linear and Jira trackers through their MCP servers (templates checked against Atlassian's supported-tools page; Linear's names filled in from the server's tool list), and checks session MCP servers as well as `.mcp.json`. For an Other tracker, checks the MCP server or CLI with one read-only call and records the exact tool names. The local markdown reference puts issues in the same `.scratch/<feature-slug>/` folders as the spec and plan |
| skills/improve-codebase-architecture | skill | mp:skills/engineering/improve-codebase-architecture | rewritten | 1.3.1 | user-only. Fully offline report (inline CSS and SVG, no Tailwind or Mermaid CDN), written to `.scratch/reports/`. Rules and a "report only" mode at the top, hot spots from a fixed `git log` command, Explore subagents with a set brief and return format, at most 6 candidates. Grilling inlined (upstream calls the `grilling` skill), ADRs through `pickle:documentation-and-adrs`, hand-off to spec-driven-development |

## Agent skills

From addyosmani/agent-skills, MIT: skills, Claude commands (`.claude/commands/`, not the Gemini `commands/*.toml`), agents, the shared `references/` folder, two host-neutral `docs/` files, and from `evals/` the `claude plugin eval` cases in `plugin/` plus the two top-level files (not the `run-evals.js` `cases/` and `fixtures/`). `scripts/vendor-sync.sh` copies each `vendored` row to the `vendor/agent-skills` branch, with the upstream `LICENSE` added (per skill, and `LICENSES/agent-skills.txt` for the rest) and `metadata.upstream` set on skills. It rewrites `agent-skills:<x>` and vendored `/command` names to pickle's namespace, and shared reference paths in `SKILL.md` files and repo paths in commands and agents to `${CLAUDE_PLUGIN_ROOT}` paths. Other files keep upstream's relative paths. Agent names stay bare, as upstream calls them, so a project or user agent with the same name overrides pickle's. Every `vendored` row has the Baseline version.

| pickle item | Kind | agent-skills source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/api-and-interface-design | skill | as:skills/api-and-interface-design | vendored | 0.6.13 | on `main`: line in When to Use that calls `pickle:codebase-design` for internal module shape |
| skills/browser-testing-with-devtools | skill | as:skills/browser-testing-with-devtools | vendored | 0.6.13 | |
| skills/ci-cd-and-automation | skill | as:skills/ci-cd-and-automation | vendored | 0.6.13 | |
| skills/code-review-and-quality | skill | as:skills/code-review-and-quality | vendored | 0.6.13 | on `main`: Readability checks names against `GLOSSARY.md` and calls `pickle:domain-modeling`; Architecture applies the deletion test from `pickle:codebase-design` |
| skills/code-simplification | skill | as:skills/code-simplification | vendored | 0.6.13 | on `main`: line after the Redundancy table that calls `pickle:codebase-design` for the deletion test, and a line after Step 1 that calls `pickle:why` |
| skills/constraint-driven-development | skill | as:skills/constraint-driven-development | vendored | 0.6.13 | on `main`: PHP suppressions in the Floor, PHP rows in the Step 4 tool table, a Composer scripts line; PHP patterns in `references/floor-guard.md` (`*Test.php`, suppressions, stubs, Pest and PHPUnit skips, `assert*`, any empty `catch`) |
| skills/context-engineering | skill | as:skills/context-engineering | vendored | 0.6.13 | on `main`: line in Level 3 that calls `pickle:how`; Laravel Boost row in MCP Integrations and a line in Level 1 to write rules outside a generated block |
| skills/debugging-and-error-recovery | skill | as:skills/debugging-and-error-recovery | vendored | 0.6.13 | on `main`: line in Step 5 that calls `pickle:codebase-design` when no seam can hold a regression test, and a line after Step 2 that calls `pickle:why` |
| skills/deprecation-and-migration | skill | as:skills/deprecation-and-migration | vendored | 0.6.13 | on `main`: line after The Deprecation Decision questions that calls `pickle:why` |
| skills/documentation-and-adrs | skill | as:skills/documentation-and-adrs | vendored | 0.6.13 | Overview adds a line on `main` that calls `pickle:technical-writing` and `pickle:why`. Also on `main`: default ADR folder `docs/adr/` (upstream `docs/decisions/`), reads `docs/agents/domain.md`, the three-part test for when an ADR is worth writing, and a line that calls `pickle:domain-modeling` when the decision names domain concepts |
| skills/doubt-driven-development | skill | as:skills/doubt-driven-development | vendored | 0.6.13 | on `main`: Interaction with Other Skills bullet that calls `pickle:how` and `pickle:why` |
| skills/frontend-ui-engineering | skill | as:skills/frontend-ui-engineering | vendored | 0.6.13 | |
| skills/git-workflow-and-versioning | skill | as:skills/git-workflow-and-versioning | vendored | 0.6.13 | |
| skills/idea-refine | skill | as:skills/idea-refine | vendored | 0.6.13 | on `main`: Usage runs the script through `${CLAUDE_SKILL_DIR}`, so it resolves outside the pickle repo; the one-pager and the script's folder are `.scratch/<feature-slug>/` |
| skills/incremental-implementation | skill | as:skills/incremental-implementation | vendored | 0.6.13 | |
| skills/interview-me | skill | as:skills/interview-me | vendored | 0.6.13 | on `main`: intent saved to `.scratch/<feature-slug>/intent.md` |
| skills/observability-and-instrumentation | skill | as:skills/observability-and-instrumentation | vendored | 0.6.13 | |
| skills/performance-optimization | skill | as:skills/performance-optimization | vendored | 0.6.13 | on `main`: experiment log in `.scratch/<feature-slug>/PERF.md` |
| skills/planning-and-task-breakdown | skill | as:skills/planning-and-task-breakdown | vendored | 0.6.13 | on `main`: External tracker follows `docs/agents/issue-tracker.md` from `/pickle:setup`, and a local markdown tracker keeps `todo.md`; plan and todo in `.scratch/<feature-slug>/`, not `tasks/` |
| skills/security-and-hardening | skill | as:skills/security-and-hardening | vendored | 0.6.13 | |
| skills/shipping-and-launch | skill | as:skills/shipping-and-launch | vendored | 0.6.13 | |
| skills/source-driven-development | skill | as:skills/source-driven-development | vendored | 0.6.13 | on `main`: lockfile versions line in Step 1, laravel.com and php.net in the source table, Step 2 reads `docs/agents/sources.md` from `/pickle:setup` |
| skills/spec-driven-development | skill | as:skills/spec-driven-development | vendored | 0.6.13 | on `main`: Code Style item names domain concepts from `GLOSSARY.md` and calls `pickle:domain-modeling`; spec, capability map and plan in `.scratch/<feature-slug>/` |
| skills/test-driven-development | skill | as:skills/test-driven-development | vendored | 0.6.13 | on `main`: line after Prefer Real Implementations Over Mocks that calls `pickle:codebase-design` |
| skills/pickle-mode | skill | as:skills/using-agent-skills | vendored | 0.6.13 | the entry skill, `/pickle:pickle-mode`. Renamed and user-only: `name: pickle-mode` and `disable-model-invocation: true` are set on `main`. Rewritten on `main` above Core Operating Behaviors: procedure, phase-ordered router with `pickle:` names, user-facing description. Upstream changes there conflict on merge |
| commands/build.md | command | as:.claude/commands/build.md | vendored | 0.6.13 | on `main`: Default reads open items from the issue tracker when `plan.md` names one; picks the feature folder from a slug argument or the one with open tasks; every skill call in the Skill tool form |
| commands/code-simplify.md | command | as:.claude/commands/code-simplify.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form |
| commands/constraints.md | command | as:.claude/commands/constraints.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form |
| commands/plan.md | command | as:.claude/commands/plan.md | vendored | 0.6.13 | on `main`: task list goes to the task list target of `pickle:planning-and-task-breakdown`, not always `todo.md`; plan and spec in `.scratch/<feature-slug>/`; every skill call in the Skill tool form |
| commands/review.md | command | as:.claude/commands/review.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form |
| commands/ship.md | command | as:.claude/commands/ship.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form |
| commands/spec.md | command | as:.claude/commands/spec.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form; spec in `.scratch/<feature-slug>/` |
| commands/test.md | command | as:.claude/commands/test.md | vendored | 0.6.13 | on `main`: every skill call in the Skill tool form |
| commands/webperf.md | command | as:.claude/commands/webperf.md | vendored | 0.6.13 | |
| agents/code-reviewer.md | agent | as:agents/code-reviewer.md | vendored | 0.6.13 | |
| agents/security-auditor.md | agent | as:agents/security-auditor.md | vendored | 0.6.13 | |
| agents/test-engineer.md | agent | as:agents/test-engineer.md | vendored | 0.6.13 | |
| agents/web-performance-auditor.md | agent | as:agents/web-performance-auditor.md | vendored | 0.6.13 | |
| references | reference | as:references | vendored | 0.6.13 | checklists and patterns shared by several skills, commands and agents |
| references/feature-folder.md | reference | - | new | n/a | the `.scratch/<feature-slug>/` layout, slug and lookup rules shared by the Define and Plan skills and commands |
| docs/agents.md | doc | as:docs/agents.md | vendored | 0.6.13 | persona orchestration rules, linked from the vendored agents |
| docs/adoption-guide.md | doc | as:docs/adoption-guide.md | vendored | 0.6.13 | greenfield and brownfield rollout; on `main`: artifacts in `.scratch/<slug>/` |
| evals/README.md | eval | as:evals/README.md | vendored | 0.6.13 | upstream's eval guide. Its Tier 1 to 3 and `run-evals.js` parts are not in pickle |
| evals/skill-impact.md | eval | as:evals/skill-impact.md | vendored | 0.6.13 | log of skill changes rejected on eval evidence |
| evals/plugin | eval | as:evals/plugin | vendored | 0.6.13 | firing evals: each skill fires on its own description, scored with and without pickle |

## Scripts

| pickle item | Kind | Source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| scripts/upstream-diff.sh | script | - | new | n/a | maintainer only |
| scripts/vendor-sync.sh | script | - | new | n/a | maintainer only, refreshes `vendor/agent-skills` |
