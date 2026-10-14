# pstack

What pstack ships and where each piece lands in pickle: skills, principles, playbooks, agents, scripts and the mod, each mapped to the Claude Code feature that replaces or overlaps it. [claude-code.md](claude-code.md) lists those features.

Source: pstack 0.15.21 in [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) at commit `997ffc7`, and its Claude Code port [PickleBoxer/pstack](https://github.com/PickleBoxer/pstack). Checked 2026-10-14. Word counts are SKILL.md plus references.

## Contents

- Skills
- Principles
- Playbooks
- Agents, scripts, mod, automations
- pstack skill to native and pickle
- pstack mechanism to native feature
- Notes for pickle

## Skills

29 skills. All but the principles have `disable-model-invocation: true`. Words are SKILL.md plus references.

| Skill | Job | Words | Calls | Called by |
|---|---|---|---|---|
| `poteto-mode` | entry: agent style, playbook index, principle index, routed skills | 19,694 (with playbooks) | how, architect, swarm, arena, interrogate, unslop, technical-writing, no-comments, benchmark-checklist, show-me-your-work, figure-it-out, reflect | user |
| `poteto-help` | help: setup, picking a skill, playbook or principle | 3,278 | index of all | user |
| `how` | how code works: 2 to 4 explorers plus explainer | 1,026 | none | playbooks, architect, teach, blast-radius, why |
| `why` | why it is this way: discovers MCPs, queries history, issues, logs | 7,865 | how | playbooks, architect, teach, recall, blast-radius |
| `architect` | sketch types and signatures first, runners plus red-flag screen, scrap loop | 2,235 | how, why, arena, interrogate | feature, bug-fix, refactor, perf, prototype, investigation |
| `arena` | N candidates, judge, graft | 676 | none | architect, eval, figure-it-out, blast-radius |
| `interrogate` | multi-model adversarial review, lead judgment | 3,109 | none | feature, bug-fix, opening-a-pr, multi-phase-plan |
| `swarm` | N parallel workers, one report | 496 | none | multi-phase-plan, autopilot-full |
| `tdd` | failing test first, only when cheap | 489 | none | bug-fix |
| `blast-radius` | what else could break, prove the safety fact | 706 | how, why, arena, unslop | user |
| `benchmark-checklist` | vet a perf number before reporting | 880 | none | perf, hillclimb, principle explain-the-number |
| `show-me-your-work` | TSV decision log | 1,076 | unslop | autonomous-run, hillclimb, autopilot, orchestrate, multi-phase-plan |
| `figure-it-out` | design a custom playbook when none fits | 632 | architect, arena, show-me-your-work | refactoring, orchestrate |
| `no-comments` | run comment-sicko, fix accepted findings | 380 | comment-sicko, architect, how, why | opening-a-pr, autopilot, multi-phase-plan |
| `unslop` | cut AI tells from writing | 891 | none | many |
| `technical-writing` | Diataxis, Google style, STE, Global English | 1,517 | unslop | opening-a-pr, multi-phase-plan |
| `typescript-best-practices` | 16 TS rules plus patterns, `paths: **/*.ts(x)` | 1,796 | principle type-system-discipline | principle type-system-discipline |
| `teach` | plain explanation | 1,018 | how, why, unslop | user |
| `recall` | rebuild recent working context | 862 | why, automate-me, unslop | user |
| `reflect` | 3 reviewers over the transcript, route learnings to skill edits | 3,055 | create-skill (Cursor) | poteto-mode |
| `correct` | make repeated agent mistakes impossible | 429 | none | user |
| `create-verification-skill` | generate a project skill that drives the app | 2,426 | maintain-verification-skill | user |
| `maintain-verification-skill` | keep that skill honest | 765 | create-verification-skill | user |
| `ketchup` | catch the user up | 490 | bro | user |
| `bro` | restate the last message plainly | 40 | none | ketchup |
| `automate-me` | capture the user's style as a mode skill | 1,053 | unslop, poteto-mode, create-skill (Cursor) | user |

## Principles

24 skills, model-invocable (pstack CI enforces it). pickle merged them into 14 plain files.

| pickle principle | pstack principles |
|---|---|
| laziness | laziness-protocol, subtract-before-you-add |
| model-the-domain | model-the-domain, foundational-thinking |
| redesign-from-first-principles | redesign-from-first-principles |
| minimize-reader-load | minimize-reader-load |
| boundaries | boundary-discipline |
| types | type-system-discipline |
| idempotent-operations | make-operations-idempotent |
| finish-migrations | migrate-callers-then-delete-legacy-apis, outcome-oriented-execution |
| no-shared-writes | separate-before-serializing-shared-state |
| prove-it-works | prove-it-works, explain-the-number |
| fix-root-causes | fix-root-causes, attack-the-premise |
| small-verified-steps | sequence-verifiable-units |
| test-behavior | test-behavior-not-implementation |
| guard-the-context | guard-the-context-window |
| (folded into playbooks) | experience-first, exhaust-the-design-space |
| (pickle authoring only) | build-the-lever, encode-lessons-in-structure |
| (replaced by profile gates) | never-block-on-the-human |

## Playbooks

| pstack | pickle | Skills pstack calls |
|---|---|---|
| feature | feature | how, architect, arena, interrogate |
| bug-fix | bug-fix | how, why, architect, interrogate, tdd |
| refactoring | refactor | figure-it-out, how, architect |
| investigation | investigate | how, why, unslop, architect |
| perf-issue | perf | benchmark-checklist, how, architect |
| prototype | prototype | architect |
| opening-a-pr | opening-a-pr | no-comments, technical-writing, unslop, interrogate |
| session-pickup | session-pickup | none |
| pause-safely | pause-safely | show-me-your-work |
| hillclimb | hillclimb | how, benchmark-checklist, show-me-your-work |
| eval | eval | arena |
| autonomous-run | autonomous-run | show-me-your-work |
| babysit | babysit | none (watch-pr script, bugbot-triage reference) |
| multi-phase-plan | multi-phase-plan | swarm, technical-writing, unslop, how, interrogate, show-me-your-work, no-comments |
| worktree-cleanup | worktree-cleanup | none (worktree-audit.sh) |
| runtime-forensics | runtime-forensics | none |
| trace-forensics | trace-forensics | none |
| visual-parity | visual-parity | none (Cursor control skills) |
| authoring-a-skill | authoring-a-skill | create-skill (Cursor) |
| shipping | dropped | Cursor control skills |
| autopilot-full | dropped | swarm, no-comments, show-me-your-work |
| autopilot-stack | dropped | no-comments, show-me-your-work |
| orchestrate | dropped | figure-it-out, arena, show-me-your-work, orch script |

## Agents, scripts, mod, automations

| Item | Job | Native equivalent | pickle |
|---|---|---|---|
| `poteto-agent` | delegate that reads poteto-mode first | custom agent with `skills:` preload, or brief with paths | `pickle-implementer` |
| `comment-sicko` | comment deletion reviewer | read-only custom agent | planned |
| `watch-pr` (Bun, about 3k lines) | poll PR checks, threads, merge queue | `/loop` plus ScheduleWakeup, Monitor on `gh pr checks --watch`, plugin monitor, `/autofix-pr` (cloud) | planned: small `pr-state.sh` |
| `orch` (Bun, about 2.8k lines) | file ledger for orchestrate | TaskCreate, `/batch`, agent teams, SendMessage | dropped |
| `check-plan.mjs` | lint a multi-phase plan | PostToolUse hook | dropped, hook later |
| `worktree-audit.sh` | audit worktrees | none for the audit | planned: port |
| `show-me-your-work/log.sh` | append a TSV decision row | none | planned: port with `show-me-your-work` |
| `bootstrap.ts` | install Bun deps | none needed | dropped |
| `sync-upstream.sh` | maintainer: upstream subtree | none | planned: `upstream-diff.sh` |
| `principle-reads.ts` | eval harness | `claude plugin eval` | dropped |
| mod `register.tsx` | Cursor translation layer, pane | mod events | drop translation, keep observability |
| `models` userConfig | search, code, judgment model | agent `model` frontmatter, Agent `model` parameter | agents carry models |
| benny automations | Cursor automations for Slack issue reports | Routines, Desktop scheduled tasks | dropped |

## pstack skill to native and pickle

Native overlap: a Claude Code feature that already does part of the job. pickle now: where it lives today. Planned: next = being ported, later = on request, dropped = not coming.

| pstack | Native overlap | pickle now | Planned |
|---|---|---|---|
| `poteto-mode` | none | `pickle-mode` | same |
| `poteto-help` | `/skills`, `/help` | none | dropped, README |
| `how` | `Explore` agent | `how` (forked lead, 1 to 3 explorers) | same |
| `why` | none (git log, `gh`, MCPs) | none | next, trimmed |
| `architect` | `Plan` agent, plan mode | `architect` (forked lead, grounds with `how`, two `Plan` runners) | same |
| `arena` | parallel Agent calls with `isolation: worktree` | none | dropped (one model family) |
| `interrogate` | `/code-review`, `/simplify`, `/security-review`, `/ultrareview` | `interrogate` (forked lead, one reviewer, `panel` opt-in) | same |
| `swarm` | `/batch`, worktree subagents, agent teams | `swarm` (forked lead, implementer workers in worktrees) | same |
| `tdd` | none | principle test-behavior | next |
| `blast-radius` | none | none | next |
| `benchmark-checklist` | none | prose in perf, hillclimb | next |
| `show-me-your-work` | none | prose in autonomous-run, pause-safely | next |
| `figure-it-out` | plan mode | none | next |
| `no-comments` | `/simplify` covers part | none | next, with `comment-sicko` |
| `unslop` | output styles do not cover it | none | next |
| `technical-writing` | none | none | next |
| `typescript-best-practices` | `.claude/rules` with `paths` | none | next, first language skill |
| `teach` | Explanatory and Learning output styles | none | later |
| `recall` | `/resume`, `/recap`, auto memory, transcripts | session-pickup playbook | later |
| `reflect` | `/insights` | none | later |
| `correct` | hooks, rules | none | later |
| `create-verification-skill` | `/run-skill-generator`, `/run`, `/verify` | profile `verify.ui` | later, compare with `/run-skill-generator` first |
| `maintain-verification-skill` | none | none | later |
| `ketchup` | `/recap` | none | later |
| `bro` | none | none | later |
| `automate-me` | auto memory, `/memory` | none | later |
| principles (24) | none | 14 files | same |

## pstack mechanism to native feature

| pstack mechanism | Native in Claude Code |
|---|---|
| Cursor Task tool, `generalPurpose`, `readonly` | Agent tool, custom agent with `tools` / `disallowedTools`, built-in `Explore` |
| model slugs, `pstack-models.mdc` | agent `model` frontmatter, Agent `model` parameter |
| cloud workers, `cloud_base_branch` | `isolation: "worktree"`, `run_in_background`, `/batch` |
| `is_background` | agent `background: true`, Agent `run_in_background` |
| AskQuestion | AskUserQuestion (main thread only) |
| loop skill | `/loop`, ScheduleWakeup, `/goal` |
| bugbot | `/code-review --comment`, `/ultrareview`, `/autofix-pr` |
| control-ui, control-cli skills | `/run`, `/verify`, `/run-skill-generator`, browser and simulator tools |
| create-skill (Cursor) | `skill-creator` skill, `/plugin-authoring` |
| "Read the skill at `../<name>/SKILL.md`" | Skill tool on a model-invocable skill |
| principle skills loaded by the Skill tool | pickle principle files read with Read |
| mod injecting poteto-mode on every prompt | not needed: `pickle-mode` is invoked once, re-attached after compaction |

## Notes for pickle

- **Nesting.** The planned `how`, `architect`, `interrogate` and `swarm` run with `context: fork` and fan out inside the fork, keeping the explorers' and reviewers' output out of the main context. A top-level fork uses no layer, so `architect` (0) calls `how` (1), whose explorers are layer 2 (measured, [claude-code.md](claude-code.md), Subagents). Fan-out calls set `run_in_background: false`, or the fork returns before its subagents. AskUserQuestion is not available inside a fork, so `architect`'s checkpoint returns to the main thread to ask.
- **`/code-review` and `/simplify`.** `interrogate` should not duplicate them. Claude can call both with the Skill tool (measured). Inferred: `interrogate` keeps intent, design and principle checks, and correctness bugs come from `/code-review`.
- **`/run-skill-generator`.** Native counterpart of `create-verification-skill`. Compare before porting.
- **Glob and Grep.** The docs say they are absent by default on macOS and Linux, but `pickle-explorer` had and used both under `claude -p` on macOS (measured). Interactive sessions are still unverified ([claude-code.md](claude-code.md), Unverified).
- **Upstream.** [UPSTREAM.md](../UPSTREAM.md) maps each pickle file to its pstack source. `scripts/upstream-diff.sh` compares against cursor/plugins directly, not the port.
