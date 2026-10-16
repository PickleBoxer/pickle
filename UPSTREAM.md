# Upstream

Where each pickle file comes from upstream (agent-skills, and pstack for `typescript-best-practices`), and the upstream version it was last compared against. The only place pickle records upstream versions. `scripts/check-refs.sh` checks this table against the files, and `scripts/upstream-diff.sh` lists what changed upstream since the baseline. `scripts/vendor-sync.sh` refreshes the `vendored` rows.

## Contents

- Baseline
- Relations
- Skills
- Agent skills
- Scripts

## Baseline

| Source | Repo | Version | Commit | Compared |
|---|---|---|---|---|
| pstack | [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) (`pstack/`) | 0.15.24 | 1e5c90a | 2026-10-14 |
| agent-skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 0.6.13 | aeac41d | 2026-10-15 |

## Relations

- `ported`: same text, small fixes.
- `rewritten`: same job, new text.
- `vendored`: upstream text, merged from the `vendor/agent-skills` branch. Local edits stay on `main` and survive each merge. Change a row to `rewritten` to stop syncing it, then keep your copy in the next merge.
- `new`: no upstream source.

A source starting with `as:` is in addyosmani/agent-skills, and its version is that repo's. Any other source is in `pstack/` of cursor/plugins.

## Skills

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/typescript-best-practices | skill | skills/typescript-best-practices | ported | 0.15.24 | model-invocable, no `paths` (ignored for plugin skills) |

## Agent skills

From addyosmani/agent-skills, MIT: skills, Claude commands (`.claude/commands/`, not the Gemini `commands/*.toml`), agents, the shared `references/` folder, two host-neutral `docs/` files, and from `evals/` the `claude plugin eval` cases in `plugin/` plus the two top-level files (not the `run-evals.js` `cases/` and `fixtures/`). `scripts/vendor-sync.sh` copies each `vendored` row to the `vendor/agent-skills` branch, with the upstream `LICENSE` added (per skill, and `LICENSES/agent-skills.txt` for the rest) and `metadata.upstream` set on skills. It rewrites `agent-skills:<x>` and vendored `/command` names to pickle's namespace, and shared reference paths in `SKILL.md` files and repo paths in commands and agents to `${CLAUDE_PLUGIN_ROOT}` paths. Other files keep upstream's relative paths. Agent names stay bare, as upstream calls them, so a project or user agent with the same name overrides pickle's. Every `vendored` row has the Baseline version.

| pickle item | Kind | agent-skills source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/api-and-interface-design | skill | as:skills/api-and-interface-design | vendored | 0.6.13 | |
| skills/browser-testing-with-devtools | skill | as:skills/browser-testing-with-devtools | vendored | 0.6.13 | |
| skills/ci-cd-and-automation | skill | as:skills/ci-cd-and-automation | vendored | 0.6.13 | |
| skills/code-review-and-quality | skill | as:skills/code-review-and-quality | vendored | 0.6.13 | |
| skills/code-simplification | skill | as:skills/code-simplification | vendored | 0.6.13 | |
| skills/constraint-driven-development | skill | as:skills/constraint-driven-development | vendored | 0.6.13 | |
| skills/context-engineering | skill | as:skills/context-engineering | vendored | 0.6.13 | |
| skills/debugging-and-error-recovery | skill | as:skills/debugging-and-error-recovery | vendored | 0.6.13 | |
| skills/deprecation-and-migration | skill | as:skills/deprecation-and-migration | vendored | 0.6.13 | |
| skills/documentation-and-adrs | skill | as:skills/documentation-and-adrs | vendored | 0.6.13 | |
| skills/doubt-driven-development | skill | as:skills/doubt-driven-development | vendored | 0.6.13 | |
| skills/frontend-ui-engineering | skill | as:skills/frontend-ui-engineering | vendored | 0.6.13 | |
| skills/git-workflow-and-versioning | skill | as:skills/git-workflow-and-versioning | vendored | 0.6.13 | |
| skills/idea-refine | skill | as:skills/idea-refine | vendored | 0.6.13 | |
| skills/incremental-implementation | skill | as:skills/incremental-implementation | vendored | 0.6.13 | |
| skills/interview-me | skill | as:skills/interview-me | vendored | 0.6.13 | |
| skills/observability-and-instrumentation | skill | as:skills/observability-and-instrumentation | vendored | 0.6.13 | |
| skills/performance-optimization | skill | as:skills/performance-optimization | vendored | 0.6.13 | |
| skills/planning-and-task-breakdown | skill | as:skills/planning-and-task-breakdown | vendored | 0.6.13 | |
| skills/security-and-hardening | skill | as:skills/security-and-hardening | vendored | 0.6.13 | |
| skills/shipping-and-launch | skill | as:skills/shipping-and-launch | vendored | 0.6.13 | |
| skills/source-driven-development | skill | as:skills/source-driven-development | vendored | 0.6.13 | |
| skills/spec-driven-development | skill | as:skills/spec-driven-development | vendored | 0.6.13 | |
| skills/test-driven-development | skill | as:skills/test-driven-development | vendored | 0.6.13 | |
| skills/pickle-mode | skill | as:skills/using-agent-skills | vendored | 0.6.13 | the entry skill, `/pickle:pickle-mode`. Renamed and user-only: `name: pickle-mode` and `disable-model-invocation: true` are set on `main`. Rewritten on `main` above Core Operating Behaviors: procedure, phase-ordered router with `pickle:` names, user-facing description. Upstream changes there conflict on merge |
| commands/build.md | command | as:.claude/commands/build.md | vendored | 0.6.13 | |
| commands/code-simplify.md | command | as:.claude/commands/code-simplify.md | vendored | 0.6.13 | |
| commands/constraints.md | command | as:.claude/commands/constraints.md | vendored | 0.6.13 | |
| commands/plan.md | command | as:.claude/commands/plan.md | vendored | 0.6.13 | |
| commands/review.md | command | as:.claude/commands/review.md | vendored | 0.6.13 | |
| commands/ship.md | command | as:.claude/commands/ship.md | vendored | 0.6.13 | |
| commands/spec.md | command | as:.claude/commands/spec.md | vendored | 0.6.13 | |
| commands/test.md | command | as:.claude/commands/test.md | vendored | 0.6.13 | |
| commands/webperf.md | command | as:.claude/commands/webperf.md | vendored | 0.6.13 | |
| agents/code-reviewer.md | agent | as:agents/code-reviewer.md | vendored | 0.6.13 | |
| agents/security-auditor.md | agent | as:agents/security-auditor.md | vendored | 0.6.13 | |
| agents/test-engineer.md | agent | as:agents/test-engineer.md | vendored | 0.6.13 | |
| agents/web-performance-auditor.md | agent | as:agents/web-performance-auditor.md | vendored | 0.6.13 | |
| references | reference | as:references | vendored | 0.6.13 | checklists and patterns shared by several skills, commands and agents |
| docs/agents.md | doc | as:docs/agents.md | vendored | 0.6.13 | persona orchestration rules, linked from the vendored agents |
| docs/adoption-guide.md | doc | as:docs/adoption-guide.md | vendored | 0.6.13 | greenfield and brownfield rollout |
| evals/README.md | eval | as:evals/README.md | vendored | 0.6.13 | upstream's eval guide. Its Tier 1 to 3 and `run-evals.js` parts are not in pickle |
| evals/skill-impact.md | eval | as:evals/skill-impact.md | vendored | 0.6.13 | log of skill changes rejected on eval evidence |
| evals/plugin | eval | as:evals/plugin | vendored | 0.6.13 | firing evals: each skill fires on its own description, scored with and without pickle |

## Scripts

| pickle item | Kind | Source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| scripts/upstream-diff.sh | script | - | new | n/a | maintainer only |
| scripts/vendor-sync.sh | script | - | new | n/a | maintainer only, refreshes `vendor/agent-skills` |
