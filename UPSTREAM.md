# Upstream

Where each pickle file comes from in pstack, and the pstack version it was last compared against. The only place pickle records upstream versions. `scripts/check-refs.sh` checks this table against the files, and `scripts/upstream-diff.sh` lists what changed upstream since the baseline.

## Contents

- Baseline
- Relations
- Skills
- Playbooks
- Principles
- Agents
- Scripts, mod and automations

## Baseline

| Source | Repo | Version | Commit | Compared |
|---|---|---|---|---|
| pstack | [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) (`pstack/`) | 0.15.24 | 1e5c90a | 2026-10-14 |
| pstack Claude port | [PickleBoxer/pstack](https://github.com/PickleBoxer/pstack) | 0.15.15+claude.7, merges 0.15.21 | fc2375c | 2026-10-14 |
| cursor-team-kit | [cursor/plugins](https://github.com/cursor/plugins/tree/main/cursor-team-kit) (`cursor-team-kit/`) | 1.2.0 | 1e5c90a | 2026-10-14 |

pickle compares against upstream pstack, not the port. pstack source paths below are relative to `pstack/` in cursor/plugins. The port is listed only for the few `port:` rows.

## Relations

- `ported`: same text, small fixes.
- `rewritten`: same job, new text.
- `rebuilt`: same job, new mechanics.
- `merged`: several pstack sources in one pickle file.
- `new`: no pstack source.
- `pending`: planned port, the pickle file does not exist yet.
- `dropped`: not coming. The row stays so an upstream change to it is noticed and ignored on purpose.

A pstack source starting with `port:` exists only in the Claude port, not upstream. A source starting with `kit:` is in `cursor-team-kit/` of cursor/plugins, not in pstack, and its version is the kit's. A pickle item `-` means no pickle file.

## Skills

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/SKILL.md | skill | skills/poteto-mode/SKILL.md | rewritten | 0.15.24 | entry skill |
| skills/how | skill | skills/how | rebuilt | 0.15.24 | forked lead, 1 to 3 explorers |
| skills/architect | skill | skills/architect | rebuilt | 0.15.24 | forked lead, grounds with `how`, two angled Plan runners, no arena. Implement and scrap phases run on the main thread |
| skills/interrogate | skill | skills/interrogate | rebuilt | 0.15.24 | forked lead, one reviewer, `panel` adds a second lens on another tier. One merged reviewer brief |
| skills/setup | skill | - | new | n/a | writes the profile |
| skills/sharpen | skill | skills/sharpen | ported | 0.15.24 | user-only |
| skills/in-your-own-words | skill | skills/in-your-own-words | ported | 0.15.24 | user-only |
| skills/swarm | skill | skills/swarm | rebuilt | 0.15.24 | forked lead, implementer workers in worktrees, foreground. Suggests `/batch` for many mechanical slices |
| skills/why | skill | skills/why | rebuilt | 0.15.24 | forked `pickle-historian` lead that writes the answer itself (no separate synthesizer), one investigator per MCP source found in its tool list. Source guides: code-archaeology, linear, notion, slack, sentry, datadog ported and trimmed, newrelic new. databricks.md and incident-postmortem.md dropped: warehouse stays a category without a guide, incident hints moved into the investigator brief |
| skills/tdd | skill | skills/tdd | rewritten | 0.15.24 | model-invocable, red step alone when a playbook delegates the fix |
| skills/unslop | skill | skills/unslop | ported | 0.15.24 | model-invocable, apply steps added, rule 13 allows parentheses |
| skills/no-comments | skill | skills/no-comments | rewritten | 0.15.24 | model-invocable, deletes in the main thread from the reviewer's report, `how` instead of `why` until `why` lands |
| skills/deslop | skill | kit:skills/deslop | rewritten | 1.2.0 | from cursor-team-kit, called by pstack before every commit. Language-agnostic, adds dead compatibility paths and unrelated edits from pstack's guide. Kept over bundled `/simplify`: narrow checklist, inline, no subagents, works without the plugin |
| skills/technical-writing | skill | skills/technical-writing | ported | 0.15.24 | model-invocable, project conventions win, snippet style follows the project |
| skills/benchmark-checklist | skill | skills/benchmark-checklist | rewritten | 0.15.24 | model-invocable, tool examples made stack-neutral, macOS core count. Where to vet moved into the perf and hillclimb playbooks |
| skills/show-me-your-work | skill | skills/show-me-your-work | rebuilt | 0.15.24 | model-invocable. `scripts/log.sh` as is. Audit reads this session's transcript by `${CLAUDE_SESSION_ID}`. Cross-model review becomes `pickle-reviewer` on another model with `references/trail-reviewer.md` |
| skills/blast-radius | skill | skills/blast-radius | pending | 0.15.24 | without `arena` |
| skills/figure-it-out | skill | skills/figure-it-out | pending | 0.15.24 | without `arena` |
| skills/typescript-best-practices | skill | skills/typescript-best-practices | pending | 0.15.24 | no `paths`: ignored for plugin skills |
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
| skills/pickle-mode/playbooks/feature.md | playbook | skills/poteto-mode/playbooks/feature.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/bug-fix.md | playbook | skills/poteto-mode/playbooks/bug-fix.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/refactor.md | playbook | skills/poteto-mode/playbooks/refactoring.md | rewritten | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/investigate.md | playbook | skills/poteto-mode/playbooks/investigation.md | rewritten | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/perf.md | playbook | skills/poteto-mode/playbooks/perf-issue.md | rewritten | 0.15.24 | renamed |
| skills/pickle-mode/playbooks/prototype.md | playbook | skills/poteto-mode/playbooks/prototype.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/opening-a-pr.md | playbook | skills/poteto-mode/playbooks/opening-a-pr.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/session-pickup.md | playbook | skills/poteto-mode/playbooks/session-pickup.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/pause-safely.md | playbook | skills/poteto-mode/playbooks/pause-safely.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/hillclimb.md | playbook | skills/poteto-mode/playbooks/hillclimb.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/eval.md | playbook | skills/poteto-mode/playbooks/eval.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/autonomous-run.md | playbook | skills/poteto-mode/playbooks/autonomous-run.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/babysit.md | playbook | skills/poteto-mode/playbooks/babysit.md, skills/poteto-mode/references/bugbot-triage.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/multi-phase-plan.md | playbook | skills/poteto-mode/playbooks/multi-phase-plan.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/worktree-cleanup.md | playbook | skills/poteto-mode/playbooks/worktree-cleanup.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/runtime-forensics.md | playbook | skills/poteto-mode/playbooks/runtime-forensics.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/trace-forensics.md | playbook | skills/poteto-mode/playbooks/trace-forensics.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/visual-parity.md | playbook | skills/poteto-mode/playbooks/visual-parity.md | rewritten | 0.15.24 | |
| skills/pickle-mode/playbooks/authoring-a-skill.md | playbook | skills/poteto-mode/playbooks/authoring-a-skill.md | rewritten | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/shipping.md | dropped | 0.15.24 | Cursor control skills |
| - | playbook | skills/poteto-mode/playbooks/autopilot-full.md | dropped | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/autopilot-stack.md | dropped | 0.15.24 | |
| - | playbook | skills/poteto-mode/playbooks/orchestrate.md | dropped | 0.15.24 | Cursor cloud agents, `orch` ledger |

## Principles

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/principles/laziness.md | principle | skills/principle-laziness-protocol, skills/principle-subtract-before-you-add | merged | 0.15.24 | |
| skills/pickle-mode/principles/model-the-domain.md | principle | skills/principle-model-the-domain, skills/principle-foundational-thinking | merged | 0.15.24 | |
| skills/pickle-mode/principles/redesign-from-first-principles.md | principle | skills/principle-redesign-from-first-principles | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/minimize-reader-load.md | principle | skills/principle-minimize-reader-load | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/boundaries.md | principle | skills/principle-boundary-discipline | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/types.md | principle | skills/principle-type-system-discipline | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/idempotent-operations.md | principle | skills/principle-make-operations-idempotent | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/finish-migrations.md | principle | skills/principle-migrate-callers-then-delete-legacy-apis, skills/principle-outcome-oriented-execution | merged | 0.15.24 | |
| skills/pickle-mode/principles/no-shared-writes.md | principle | skills/principle-separate-before-serializing-shared-state | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/prove-it-works.md | principle | skills/principle-prove-it-works, skills/principle-explain-the-number | merged | 0.15.24 | |
| skills/pickle-mode/principles/fix-root-causes.md | principle | skills/principle-fix-root-causes, skills/principle-attack-the-premise | merged | 0.15.24 | |
| skills/pickle-mode/principles/small-verified-steps.md | principle | skills/principle-sequence-verifiable-units | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/test-behavior.md | principle | skills/principle-test-behavior-not-implementation | rewritten | 0.15.24 | |
| skills/pickle-mode/principles/guard-the-context.md | principle | skills/principle-guard-the-context-window | rewritten | 0.15.24 | |
| - | principle | skills/principle-experience-first | dropped | 0.15.24 | folded into playbooks |
| - | principle | skills/principle-exhaust-the-design-space | dropped | 0.15.24 | folded into playbooks |
| - | principle | skills/principle-build-the-lever | dropped | 0.15.24 | pickle authoring only |
| - | principle | skills/principle-encode-lessons-in-structure | dropped | 0.15.24 | pickle authoring only |
| - | principle | skills/principle-never-block-on-the-human | dropped | 0.15.24 | replaced by profile gates |

## Agents

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| agents/pickle-lead.md | agent | - | new | n/a | read-only fork agent for `how`, `architect`, `interrogate` |
| agents/pickle-explorer.md | agent | - | new | n/a | explorer role from `how` |
| agents/pickle-implementer.md | agent | agents/poteto-agent.md | rewritten | 0.15.24 | |
| agents/pickle-reviewer.md | agent | - | new | n/a | reviewer role from `interrogate` |
| agents/pickle-historian.md | agent | - | new | n/a | lead and investigators for `why`. No tools list so it inherits MCP tools, denies Edit, Write, NotebookEdit |
| agents/comment-sicko.md | agent | agents/comment-sicko.md | rewritten | 0.15.24 | read-only, report only, plain voice, git history instead of `how` and `why` |

## Scripts, mod and automations

| pickle item | Kind | pstack source | Relation | Upstream version | Notes |
|---|---|---|---|---|---|
| skills/pickle-mode/scripts/worktree-audit.sh | script | skills/poteto-mode/scripts/worktree-audit.sh | pending | 0.15.24 | Claude transcript path, portable `stat` and `date` |
| skills/pickle-mode/scripts/pr-state.sh | script | skills/poteto-mode/scripts/watch-pr | pending | 0.15.24 | about 40 lines instead of the Bun tool |
| - | script | skills/poteto-mode/scripts/orch | dropped | 0.15.24 | with `orchestrate` |
| - | script | skills/poteto-mode/scripts/check-plan.mjs | dropped | 0.15.24 | playbook reread step covers it |
| - | script | skills/poteto-mode/scripts/bootstrap.ts | dropped | 0.15.24 | no Bun tools left |
| scripts/upstream-diff.sh | script | port:scripts/sync-upstream.sh | rewritten | n/a | maintainer only |
| - | script | port:scripts/principle-reads.ts | dropped | n/a | `claude plugin eval` |
| - | mod | port:hooks | dropped | n/a | translation layer. pickle's planned mod keeps only observability |
| - | automation | automations/benny | dropped | 0.15.24 | Cursor automations |
