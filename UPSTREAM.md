# Upstream

Where each pickle file comes from upstream (pstack, cursor-team-kit, agent-skills), and the upstream version it was last compared against. The only place pickle records upstream versions. `scripts/check-refs.sh` checks this table against the files, and `scripts/upstream-diff.sh` lists what changed upstream since the baseline. `scripts/vendor-sync.sh` refreshes the `vendored` rows.

## Contents

- Baseline
- Relations
- Skills
- Playbooks
- Principles
- Agents
- Agent skills
- Scripts, mod and automations

## Baseline

| Source | Repo | Version | Commit | Compared |
|---|---|---|---|---|
| pstack | [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) (`pstack/`) | 0.15.24 | 1e5c90a | 2026-10-14 |
| pstack Claude port | [PickleBoxer/pstack](https://github.com/PickleBoxer/pstack) | 0.15.15+claude.7, merges 0.15.21 | fc2375c | 2026-10-14 |
| cursor-team-kit | [cursor/plugins](https://github.com/cursor/plugins/tree/main/cursor-team-kit) (`cursor-team-kit/`) | 1.2.0 | 1e5c90a | 2026-10-14 |
| agent-skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 0.6.13 | aeac41d | 2026-10-15 |

pickle compares against upstream pstack, not the port. pstack source paths below are relative to `pstack/` in cursor/plugins. The port is listed only for the few `port:` rows.

## Relations

- `ported`: same text, small fixes.
- `rewritten`: same job, new text.
- `rebuilt`: same job, new mechanics.
- `merged`: several pstack sources in one pickle file.
- `vendored`: upstream text, merged from the `vendor/agent-skills` branch. Local edits stay on `main` and survive each merge. Change a row to `rewritten` to stop syncing it, then keep your copy in the next merge.
- `new`: no pstack source.
- `pending`: not shipped. A planned port, or a piece removed for the agent-skills baseline, re-added when an eval or real use shows the gap. Notes describe the last shipped version.
- `dropped`: not coming. The row stays so an upstream change to it is noticed and ignored on purpose.

A pstack source starting with `port:` exists only in the Claude port, not upstream. A source starting with `kit:` is in `cursor-team-kit/` of cursor/plugins, not in pstack, and its version is the kit's. A source starting with `as:` is in addyosmani/agent-skills, and its version is that repo's. A pickle item `-` means no pickle file.

## Skills

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| - | skill | skills/poteto-mode/SKILL.md | dropped | 0.15.24 | `pickle-mode` is now the vendored `using-agent-skills`, see Agent skills |
| skills/how | skill | skills/how | pending | 0.15.24 | forked lead, 1 to 3 explorers |
| skills/architect | skill | skills/architect | pending | 0.15.24 | forked lead, grounds with `how`, two angled Plan runners, no arena. Implement and scrap phases run on the main thread |
| skills/interrogate | skill | skills/interrogate | pending | 0.15.24 | forked lead, one reviewer, `panel` adds a second lens on another tier. One merged reviewer brief |
| skills/setup | skill | - | pending | n/a | writes the profile `.claude/pickle.md`, which nothing reads now |
| skills/sharpen | skill | skills/sharpen | pending | 0.15.24 | user-only |
| skills/in-your-own-words | skill | skills/in-your-own-words | pending | 0.15.24 | user-only |
| skills/swarm | skill | skills/swarm | pending | 0.15.24 | forked lead, implementer workers in worktrees, foreground. Suggests `/batch` for many mechanical slices |
| skills/why | skill | skills/why | pending | 0.15.24 | forked `pickle-historian` lead that writes the answer itself (no separate synthesizer), one investigator per MCP source found in its tool list. Source guides: code-archaeology, linear, notion, slack, sentry, datadog ported and trimmed, newrelic new. databricks.md and incident-postmortem.md dropped: warehouse stays a category without a guide, incident hints moved into the investigator brief |
| skills/tdd | skill | skills/tdd | pending | 0.15.24 | model-invocable, red step alone when a playbook delegates the fix |
| skills/unslop | skill | skills/unslop | pending | 0.15.24 | model-invocable, apply steps added, rule 13 allows parentheses |
| skills/no-comments | skill | skills/no-comments | pending | 0.15.24 | model-invocable, deletes in the main thread from the reviewer's report, `how` instead of `why` until `why` lands |
| skills/deslop | skill | kit:skills/deslop | pending | 1.2.0 | from cursor-team-kit, called by pstack before every commit. Language-agnostic, adds dead compatibility paths and unrelated edits from pstack's guide. Kept over bundled `/simplify`: narrow checklist, inline, no subagents, works without the plugin |
| skills/technical-writing | skill | skills/technical-writing | pending | 0.15.24 | model-invocable, project conventions win, snippet style follows the project |
| skills/benchmark-checklist | skill | skills/benchmark-checklist | pending | 0.15.24 | model-invocable, tool examples made stack-neutral, macOS core count. Where to vet moved into the perf and hillclimb playbooks |
| skills/show-me-your-work | skill | skills/show-me-your-work | pending | 0.15.24 | model-invocable. `scripts/log.sh` as is. Audit reads this session's transcript by `${CLAUDE_SESSION_ID}`. Cross-model review becomes `pickle-reviewer` on another model with `references/trail-reviewer.md` |
| skills/blast-radius | skill | skills/blast-radius | pending | 0.15.24 | model-invocable (pstack has it user-only), inline. The `arena` step becomes `interrogate panel`. Framework examples made stack-neutral. No playbook calls it, as in pstack |
| skills/figure-it-out | skill | skills/figure-it-out | pending | 0.15.24 | model-invocable (pstack has it user-only), inline. `architect` runs with sign-off instead of `arena`. Principle skills mapped to pickle principle files; never-block-on-the-human becomes profile gates plus one checkpoint, encode-lessons-in-structure becomes plain text. Adds `how` grounding, `swarm` for fan-out and `interrogate` as the judge |
| skills/typescript-best-practices | skill | skills/typescript-best-practices | ported | 0.15.24 | model-invocable, no `paths` (ignored for plugin skills) |
| skills/teach | skill | skills/teach | pending | 0.15.24 | later, on request |
| skills/recall | skill | skills/recall | pending | 0.15.24 | later, on request |
| skills/reflect | skill | skills/reflect | pending | 0.15.24 | later, on request |
| skills/correct | skill | skills/correct | pending | 0.15.24 | later, on request |
| skills/create-verification-skill | skill | skills/create-verification-skill | pending | 0.15.24 | later, compare with `/run-skill-generator` first |
| skills/maintain-verification-skill | skill | skills/maintain-verification-skill | pending | 0.15.24 | later, on request |
| skills/ketchup | skill | skills/ketchup | pending | 0.15.24 | later, on request |
| skills/bro | skill | skills/bro | pending | 0.15.24 | later, on request |
| skills/automate-me | skill | skills/automate-me | pending | 0.15.24 | later, on request |
| - | skill | skills/arena | dropped | 0.15.24 | one model family |
| - | skill | skills/poteto-help | dropped | 0.15.24 | README plus the `pickle-mode` index |

## Playbooks

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/playbooks/feature.md | playbook | skills/poteto-mode/playbooks/feature.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/bug-fix.md | playbook | skills/poteto-mode/playbooks/bug-fix.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/refactor.md | playbook | skills/poteto-mode/playbooks/refactoring.md | pending | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/investigate.md | playbook | skills/poteto-mode/playbooks/investigation.md | pending | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/perf.md | playbook | skills/poteto-mode/playbooks/perf-issue.md | pending | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/prototype.md | playbook | skills/poteto-mode/playbooks/prototype.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/opening-a-pr.md | playbook | skills/poteto-mode/playbooks/opening-a-pr.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/session-pickup.md | playbook | skills/poteto-mode/playbooks/session-pickup.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/pause-safely.md | playbook | skills/poteto-mode/playbooks/pause-safely.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/hillclimb.md | playbook | skills/poteto-mode/playbooks/hillclimb.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/eval.md | playbook | skills/poteto-mode/playbooks/eval.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/autonomous-run.md | playbook | skills/poteto-mode/playbooks/autonomous-run.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/babysit.md | playbook | skills/poteto-mode/playbooks/babysit.md, skills/poteto-mode/references/bugbot-triage.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/multi-phase-plan.md | playbook | skills/poteto-mode/playbooks/multi-phase-plan.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/worktree-cleanup.md | playbook | skills/poteto-mode/playbooks/worktree-cleanup.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/runtime-forensics.md | playbook | skills/poteto-mode/playbooks/runtime-forensics.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/trace-forensics.md | playbook | skills/poteto-mode/playbooks/trace-forensics.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/visual-parity.md | playbook | skills/poteto-mode/playbooks/visual-parity.md | pending | 0.15.24 | |
| skills/pickle-mode/playbooks/authoring-a-skill.md | playbook | skills/poteto-mode/playbooks/authoring-a-skill.md | pending | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/shipping.md | dropped | 0.15.24 | Cursor control skills |
| - | playbook | skills/poteto-mode/playbooks/autopilot-full.md | dropped | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/autopilot-stack.md | dropped | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/orchestrate.md | dropped | 0.15.24 | Cursor cloud agents, `orch` ledger |

## Principles

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/principles/laziness.md | principle | skills/principle-laziness-protocol, skills/principle-subtract-before-you-add | pending | 0.15.24 | |
| skills/pickle-mode/principles/model-the-domain.md | principle | skills/principle-model-the-domain, skills/principle-foundational-thinking | pending | 0.15.24 | |
| skills/pickle-mode/principles/redesign-from-first-principles.md | principle | skills/principle-redesign-from-first-principles | pending | 0.15.24 | |
| skills/pickle-mode/principles/minimize-reader-load.md | principle | skills/principle-minimize-reader-load | pending | 0.15.24 | |
| skills/pickle-mode/principles/boundaries.md | principle | skills/principle-boundary-discipline | pending | 0.15.24 | |
| skills/pickle-mode/principles/types.md | principle | skills/principle-type-system-discipline | pending | 0.15.24 | |
| skills/pickle-mode/principles/idempotent-operations.md | principle | skills/principle-make-operations-idempotent | pending | 0.15.24 | |
| skills/pickle-mode/principles/finish-migrations.md | principle | skills/principle-migrate-callers-then-delete-legacy-apis, skills/principle-outcome-oriented-execution | pending | 0.15.24 | |
| skills/pickle-mode/principles/no-shared-writes.md | principle | skills/principle-separate-before-serializing-shared-state | pending | 0.15.24 | |
| skills/pickle-mode/principles/prove-it-works.md | principle | skills/principle-prove-it-works, skills/principle-explain-the-number | pending | 0.15.24 | |
| skills/pickle-mode/principles/fix-root-causes.md | principle | skills/principle-fix-root-causes, skills/principle-attack-the-premise | pending | 0.15.24 | |
| skills/pickle-mode/principles/small-verified-steps.md | principle | skills/principle-sequence-verifiable-units | pending | 0.15.24 | |
| skills/pickle-mode/principles/test-behavior.md | principle | skills/principle-test-behavior-not-implementation | pending | 0.15.24 | |
| skills/pickle-mode/principles/guard-the-context.md | principle | skills/principle-guard-the-context-window | pending | 0.15.24 | |
| - | principle | skills/principle-experience-first | dropped | 0.15.24 | folded into playbooks |
| - | principle | skills/principle-exhaust-the-design-space | dropped | 0.15.24 | folded into playbooks |
| - | principle | skills/principle-build-the-lever | dropped | 0.15.24 | pickle authoring only |
| - | principle | skills/principle-encode-lessons-in-structure | dropped | 0.15.24 | pickle authoring only |
| - | principle | skills/principle-never-block-on-the-human | dropped | 0.15.24 | replaced by profile gates |

## Agents

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| agents/pickle-lead.md | agent | - | pending | n/a | read-only fork agent for `how` |
| agents/pickle-explorer.md | agent | - | pending | n/a | explorer role from `how` |
| agents/pickle-implementer.md | agent | agents/poteto-agent.md | pending | 0.15.24 | |
| agents/pickle-reviewer.md | agent | - | pending | n/a | reviewer role from `interrogate` |
| agents/pickle-historian.md | agent | - | pending | n/a | lead and investigators for `why`. No tools list so it inherits MCP tools, denies Edit, Write, NotebookEdit |
| agents/comment-sicko.md | agent | agents/comment-sicko.md | pending | 0.15.24 | read-only, report only, plain voice, git history instead of `how` and `why` |

## Agent skills

From addyosmani/agent-skills, MIT: skills, Claude commands (`.claude/commands/`, not the Gemini `commands/*.toml`), agents, and from `evals/` the `claude plugin eval` cases in `plugin/` plus the two top-level files (not the `run-evals.js` `cases/` and `fixtures/`). `scripts/vendor-sync.sh` copies each `vendored` row to the `vendor/agent-skills` branch, with the shared root `references/` files a skill links copied into its own `references/` folder, the upstream `LICENSE` added (per skill, and `LICENSES/agent-skills.txt` for commands and agents) and `metadata.upstream` set on skills. It rewrites `agent-skills:<x>` and vendored `/command` names to pickle's namespace, and repo paths in commands and agents to `${CLAUDE_PLUGIN_ROOT}` paths. Agent names stay bare, as upstream calls them, so a project or user agent with the same name overrides pickle's. Every `vendored` row has the Baseline version.

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
| skills/pickle-mode | skill | as:skills/using-agent-skills | vendored | 0.6.13 | the entry skill, `/pickle:pickle-mode`. Renamed and user-only: `name: pickle-mode` and `disable-model-invocation: true` are set on `main` |
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
| evals/README.md | eval | as:evals/README.md | vendored | 0.6.13 | upstream's eval guide. Its Tier 1 to 3 and `run-evals.js` parts are not in pickle |
| evals/skill-impact.md | eval | as:evals/skill-impact.md | vendored | 0.6.13 | log of skill changes rejected on eval evidence |
| evals/plugin | eval | as:evals/plugin | vendored | 0.6.13 | firing evals: each skill fires on its own description, scored with and without pickle |
| - | eval | as:evals/cases | dropped | n/a | Tier 2 and 3 cases for upstream's `run-evals.js` |
| - | eval | as:evals/fixtures | dropped | n/a | Tier 3 fixtures for upstream's `run-evals.js` |

## Scripts, mod and automations

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/scripts/worktree-audit.sh | script | skills/poteto-mode/scripts/worktree-audit.sh | pending | 0.15.24 | Claude transcript path (`projects/<slug>/`, own folder plus main-checkout search), portable `stat` and `date`, `grep -F` for `rg`, `jq` check, CLAUDE column (`.claude/worktrees/` path) |
| skills/pickle-mode/scripts/pr-state.sh | script | skills/poteto-mode/scripts/watch-pr | pending | 0.15.24 | one-shot state in bash instead of the Bun poller: `gh pr view` plus GraphQL review threads. Waiting is Monitor on `gh pr checks --watch` |
| - | script | skills/poteto-mode/scripts/orch | dropped | 0.15.24 | with `orchestrate` |
| - | script | skills/poteto-mode/scripts/check-plan.mjs | dropped | 0.15.24 | playbook reread step covers it |
| - | script | skills/poteto-mode/scripts/bootstrap.ts | dropped | 0.15.24 | no Bun tools left |
| scripts/upstream-diff.sh | script | port:scripts/sync-upstream.sh | rewritten | n/a | maintainer only |
| scripts/vendor-sync.sh | script | - | new | n/a | maintainer only, refreshes `vendor/agent-skills` |
| - | script | port:scripts/principle-reads.ts | dropped | n/a | `claude plugin eval` |
| - | mod | port:hooks | dropped | n/a | translation layer. pickle's planned mod keeps only observability |
| - | automation | automations/benny | dropped | 0.15.24 | Cursor automations |
