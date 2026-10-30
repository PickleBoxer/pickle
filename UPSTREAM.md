# Upstream

Where each pickle file comes from upstream (agent-skills, pstack for `typescript-best-practices`, `unslop`, `technical-writing`, `how`, `why`, `blast-radius`, `reflect`, `teach`, `sharpen`, performance-optimization's benchmark checklist and codebase-design's sketch-first reference, and mattpocock-skills for `codebase-design`, `domain-modeling`, `setup`, `improve-codebase-architecture` and `prototype`), and the upstream version and commit it was last compared against. The Grafts table does the same for sections a pickle file took from a second source. The only place pickle records upstream versions. `scripts/check-refs.sh` checks these tables against the files, and `scripts/upstream-diff.sh` lists what changed upstream since the baseline. `scripts/vendor-sync.sh` refreshes the `vendored` rows.

## Contents

- Baseline
- Relations
- Skills
- Matt Pocock skills
- Agent skills
- Grafts
- pickle skills
- Mods
- Scripts

## Baseline

| Source | Repo | Version | Commit | Compared |
|---|---|---|---|---|
| pstack | [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) (`pstack/`) | 0.15.25 | 99743e9 | 2026-10-16 |
| agent-skills | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 0.6.13 | aeac41d | 2026-10-15 |
| mattpocock-skills | [mattpocock/skills](https://github.com/mattpocock/skills) | 1.3.1 | 59db609 | 2026-10-28 |

## Relations

- `ported`: same text, small fixes.
- `rewritten`: same job, new text.
- `vendored`: upstream text, merged from the `vendor/agent-skills` branch. Local edits stay on `main` and survive each merge. Change a row to `rewritten` to stop syncing it, then keep your copy in the next merge.
- `new`: no upstream source.

A source starting with `as:` is in addyosmani/agent-skills, and one starting with `mp:` is in mattpocock/skills; each version and commit is that repo's. Any other source is in `pstack/` of cursor/plugins. A row's Commit is the upstream commit it was last compared against, and `scripts/upstream-diff.sh` diffs from it, so a row can be ahead of its Baseline.

Notes on a `vendored` row start with or contain "on `main`" exactly when the file differs from the `vendor/agent-skills` branch, and then say how. `scripts/check-refs.sh` checks both directions.

## Skills

| pickle item | Kind | pstack source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| skills/typescript-best-practices | skill | skills/typescript-best-practices | ported | 0.15.29 | 88d4751 | model-invocable, no `paths` (ignored for plugin skills) |
| skills/unslop | skill | skills/unslop | ported | 0.15.25 | 99743e9 | model-invocable (user-only upstream), so other skills can call it. Adds a scope line. Rule numbers kept: other skills cite them |
| skills/technical-writing | skill | skills/technical-writing | ported | 0.15.25 | 99743e9 | model-invocable (user-only upstream). Calls `pickle:unslop`, drops the rules unslop already owns, project conventions win, no Cursor house rules. Adds a PR descriptions section from pstack's Opening a PR playbook (Why, What changed, Scope, Tradeoffs, Blast radius, Verification), after the repo's own template |
| skills/how | skill | skills/how | rewritten | 0.15.25 | 99743e9 | model-invocable. Claude Code Agent tool (Explore explorers), no per-role models. Simple questions and the explanation are written inline, not by an explainer subagent. Uses `GLOSSARY.md` terms when the project has one |
| skills/why | skill | skills/why | rewritten | 0.15.25 | 99743e9 | model-invocable. Claude Code Agent tool and ToolSearch for MCP discovery, no per-role models. Answers inline when only source control is available. Source guides renamed by category, `source-playbook.md` folded into `SKILL.md`, warehouse guide made generic. Uses `GLOSSARY.md` terms when the project has one |
| skills/codebase-design/references/sketch-first.md | reference | skills/architect | rewritten | 0.15.25 | 99743e9 | reference of the `codebase-design` extension, so it calls no skill: the how and why grounding phase and the arena runners are dropped, and design-it-twice covers parallel shapes. Merges the runner prompt's discipline, the red flags codebase-design lacked (as a table) and a shorter rationale template. Shows the sketch and waits before implementing (pstack goes straight on). Uses codebase-design's vocabulary |
| skills/blast-radius | skill | skills/blast-radius | rewritten | 0.15.25 | 99743e9 | model-invocable (user-only upstream), routed from pickle-mode Review. Calls `pickle:how`, `pickle:why` and `pickle:unslop` in the Skill tool form. Drops the arena step for wide changes (no model panels), the Solid and React timing example and the duplicated Reply line. Ladder levels named (Said, Pointed, Walked, Ran, Reproduced). Firing eval `blast-radius-fires` |
| skills/reflect | skill | skills/reflect | rewritten | 0.15.25 | 99743e9 | user-only. Merged with mattpocock-skills `skills/engineering/retro`: its environment categories became the environment lens, and its rule that a mechanical violation gets a check became the deterministic-first criterion. `scripts/digest.sh` finds the transcript from `${CLAUDE_SESSION_ID}`, keeps to this project's folder and prints the deterministic signals. Judgment and divergent lenses merged, tooling lens adds tool economy. Reviewers only above 50 tool calls, synthesis inline, no per-role models. Routings name Claude Code homes (hooks, `.claude/rules/`, auto memory, `/doctor prompt-audit`); larger skill edits go to `skill-creator:skill-creator` |
| skills/teach | skill | skills/teach | rewritten | 0.15.29 | 88d4751 | user-only. Calls `pickle:how`, `pickle:why` and `pickle:unslop` in the Skill tool form (all model-invocable in pickle; `why` is user-only upstream). Diagrams are ASCII in code blocks, not Mermaid or generated images (Claude Code has no image tool). Narrowing `why` names the evidence categories to skip, so `why` records them in Sources Consulted. Code shown as `file:line` excerpts or `git diff` hunks, no debugger. Voice rules that `unslop` owns dropped; adds `$ARGUMENTS` and `GLOSSARY.md` terms |
| skills/performance-optimization/references/benchmark-checklist.md | reference | skills/benchmark-checklist | ported | 0.15.25 | 99743e9 | reference of a vendored skill, not a skill: no frontmatter. Adds the macOS core count, drops the pstack playbook links, and sends run evidence to `PERF.md` |
| skills/sharpen | skill | skills/sharpen | ported | 0.15.29 | 88d4751 | user-only. Text from #729 (rewrite only, does not do the task). Adds `$ARGUMENTS`, examples of raw material and outside checks, the prompt in one fenced code block, and "Don't start the task" |

## Matt Pocock skills

From mattpocock/skills, MIT. `codebase-design` and `domain-modeling` are **extensions**: hidden from the `/` menu (`user-invocable: false`), called by the workflow skills, and calling no other skill (`scripts/check-refs.sh` enforces it). `setup` and `improve-codebase-architecture` are user-only entry points outside the workflow. Reference files moved to `references/`, lowercase. No `agents/openai.yaml` (Codex only).

| pickle item | Kind | mattpocock-skills source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| skills/codebase-design | skill | mp:skills/engineering/codebase-design | ported | 1.3.1 | 59db609 | extension. Description narrowed to internal module shape, not HTTP or public API contracts. Design-it-twice names the Agent tool with `Plan` subagents. Going deeper links `references/sketch-first.md` (pstack row) |
| skills/domain-modeling | skill | mp:skills/engineering/domain-modeling | rewritten | 1.3.1 | 59db609 | extension, glossary only: ADR-FORMAT.md and the ADR rules dropped, since documentation-and-adrs owns ADRs and calls this skill for their terms. Reads `docs/agents/domain.md` when present |
| skills/setup | skill | mp:skills/engineering/setup-matt-pocock-skills | rewritten | 1.3.1 | 59db609 | user-only, `/pickle:setup`. Issue tracker, domain docs and docs sources (`docs/agents/sources.md`, read by source-driven-development); offers `pickle:constraint-driven-development` when there is no `CONSTRAINTS.md`, writes the general boundaries guide `docs/agents/boundaries.md` from `references/boundaries.md` (Section E), writes the review lanes and checks `docs/agents/review.md` from `references/review.md` (Section F, read by code-review-and-quality), and keeps the Agent skills block outside a generated block such as Boost's. Otherwise no triage labels, no wayfinder operations, no PR triage flag. Default ADR folder `docs/adr/`. Adds optional glossary seeding through an Explore subagent and `pickle:domain-modeling`. Edits `AGENTS.md` when `CLAUDE.md` only imports it. Adds Linear and Jira trackers through their MCP servers (templates checked against Atlassian's supported-tools page; Linear's names filled in from the server's tool list), and checks session MCP servers as well as `.mcp.json`. For an Other tracker, checks the MCP server or CLI with one read-only call and records the exact tool names. A GitHub or GitLab tracker needs a remote `gh repo view` or `glab repo view` can reach; an older `CONTEXT.md` or `CONTEXT-MAP.md` is offered a rename to its `GLOSSARY` name. The GitHub template comments before closing and confirms the target repo in a fork The local markdown reference keeps issues flat in `tasks/issues/`, next to the active plan, instead of `.scratch/<feature>/` |
| skills/prototype | skill | mp:skills/engineering/prototype | rewritten | 1.3.1 | 59db609 | model-invocable, routed from pickle-mode Define. Merged with pstack's Prototype playbook: name the decision first, prototype before asking a question running something can answer, a third branch for behavior and timing, propose variants, present and wait. `LOGIC.md` and `UI.md` moved to `references/logic.md` and `references/ui.md` with links fixed. The verdict goes in the throwaway branch's commit message, with a pointer from the issue, `SPEC.md` or `tasks/plan.md`; the real build hands off to `pickle:incremental-implementation`. No `agents/openai.yaml`. Firing eval `prototype-fires` |
| skills/improve-codebase-architecture | skill | mp:skills/engineering/improve-codebase-architecture | rewritten | 1.3.1 | 59db609 | user-only. Fully offline report (inline CSS and SVG, no Tailwind or Mermaid CDN), written to `docs/agents/reports/`. Rules and a "report only" mode at the top, hot spots from a fixed `git log` command, Explore subagents with a set brief and return format, at most 6 candidates. Grilling inlined (upstream calls the `grilling` skill), ADRs through `pickle:documentation-and-adrs`, hand-off to spec-driven-development |

## Agent skills

From addyosmani/agent-skills, MIT: skills, Claude commands (`.claude/commands/`, not the Gemini `commands/*.toml`), agents, the shared `references/` folder, two host-neutral `docs/` files, and from `evals/` the `claude plugin eval` cases in `plugin/` plus the two top-level files (not the `run-evals.js` `cases/` and `fixtures/`). `scripts/vendor-sync.sh` copies each `vendored` row to the `vendor/agent-skills` branch, with the upstream `LICENSE` added (per skill, and `LICENSES/agent-skills.txt` for the rest) and `metadata.upstream` set on skills. It rewrites `agent-skills:<x>` and vendored `/command` names to pickle's namespace, and shared reference paths in `SKILL.md` files and repo paths in commands and agents to `${CLAUDE_PLUGIN_ROOT}` paths. Other files keep upstream's relative paths. Agent names stay bare, as upstream calls them, so a project or user agent with the same name overrides pickle's. Every `vendored` row has the Baseline version.

| pickle item | Kind | agent-skills source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| skills/api-and-interface-design | skill | as:skills/api-and-interface-design | vendored | 0.6.13 | aeac41d | on `main`: line in When to Use that calls `pickle:codebase-design` for internal module shape |
| skills/browser-testing-with-devtools | skill | as:skills/browser-testing-with-devtools | vendored | 0.6.13 | aeac41d | |
| skills/ci-cd-and-automation | skill | as:skills/ci-cd-and-automation | vendored | 0.6.13 | aeac41d | |
| skills/code-review-and-quality | skill | as:skills/code-review-and-quality | vendored | 0.6.13 | aeac41d | on `main`: Readability checks names against `GLOSSARY.md` and calls `pickle:domain-modeling`; Architecture applies the deletion test from `pickle:codebase-design` and escalates a rule flagged twice through `docs/agents/boundaries.md`; Repo Lanes section after the five axes, which runs the lanes and checks in a project's `docs/agents/review.md` and names skipped lanes (pickle's own, replacing the user's dotfiles review lanes); Judging Reviewer Findings section before Dead Code Hygiene (from pstack's interrogate lead judgment, without its model panel; upstream deleted it, and point 3 now follows interrogate's rule that a finding counts when a run proves it) |
| skills/code-simplification | skill | as:skills/code-simplification | vendored | 0.6.13 | aeac41d | on `main`: line after the Redundancy table that calls `pickle:codebase-design` for the deletion test, and a line after Step 1 that calls `pickle:why` |
| skills/constraint-driven-development | skill | as:skills/constraint-driven-development | vendored | 0.6.13 | aeac41d | on `main`: PHP suppressions in the Floor, PHP rows in the Step 4 tool table, a Composer scripts line; Step 1 detects PHP and Swift configs and existing boundaries and points rules about the code at `AGENTS.md` and `docs/agents/boundaries.md`; Step 4 rows for deptrac, import-linter, depguard, Semgrep rules, PHP-CS-Fixer and PHPCS, Rector, Pest type coverage, Psalm taint analysis, roave/security-advisories and Pest mutate; the pointer line goes in one instruction file; Step 6 lists PHP config moves and puts `CONSTRAINTS.md` under `CODEOWNERS`; PHPStan level and baseline defaults; PHP patterns in `references/floor-guard.md` (`*Test.php`, suppressions, stubs, Pest and PHPUnit skips, `assert*`, any empty `catch`) |
| skills/context-engineering | skill | as:skills/context-engineering | vendored | 0.6.13 | aeac41d | on `main`: line in Level 3 that calls `pickle:how`; Laravel Boost row in MCP Integrations; Level 1 lines to edit one instruction file and to write rules outside a generated block |
| skills/debugging-and-error-recovery | skill | as:skills/debugging-and-error-recovery | vendored | 0.6.13 | aeac41d | on `main`: line in Step 5 that calls `pickle:codebase-design` when no seam can hold a regression test, and a line after Step 2 that calls `pickle:why`. Also on `main`, from pstack's Bug fix playbook and principles: reproduce it yourself (Step 1), rule causes out with runtime evidence and `pickle:how` (Step 2), fix every instance and the two-failed-fixes stop (Step 4), Step 5 points to Prove-It when no cheap test exists, Safe Fallback Patterns limited to boundaries with a fail-fast config example and the legitimate-state test for guards |
| skills/deprecation-and-migration | skill | as:skills/deprecation-and-migration | vendored | 0.6.13 | aeac41d | on `main`: line after The Deprecation Decision questions that calls `pickle:why`; Internal APIs section before The Migration Process (from pstack's migrate-callers-then-delete-legacy-apis principle): migrate every in-repo caller and delete the old API in the same change |
| skills/documentation-and-adrs | skill | as:skills/documentation-and-adrs | vendored | 0.6.13 | aeac41d | Overview adds a line on `main` that calls `pickle:technical-writing` and `pickle:why`. Also on `main`: default ADR folder `docs/adr/` (upstream `docs/decisions/`), reads `docs/agents/domain.md`, the three-part test for when an ADR is worth writing, and a line that calls `pickle:domain-modeling` when the decision names domain concepts |
| skills/doubt-driven-development | skill | as:skills/doubt-driven-development | vendored | 0.6.13 | aeac41d | on `main`: Interaction with Other Skills bullet that calls `pickle:how` and `pickle:why`; RECONCILE line that calls `pickle:code-review-and-quality` for its Judging Reviewer Findings filters before a finding is called noise |
| skills/frontend-ui-engineering | skill | as:skills/frontend-ui-engineering | vendored | 0.6.13 | aeac41d | on `main`: the "just a prototype" rationalization row names `pickle:prototype` throwaways as the exception |
| skills/git-workflow-and-versioning | skill | as:skills/git-workflow-and-versioning | vendored | 0.6.13 | aeac41d | on `main`: commit-order paragraph in Keep Concerns Separate (removals, reshape, new behavior), from pstack's sequence-verifiable-units principle |
| skills/idea-refine | skill | as:skills/idea-refine | vendored | 0.6.13 | aeac41d | on `main`: Usage runs the script through `${CLAUDE_SKILL_DIR}`, so it resolves outside the pickle repo |
| skills/incremental-implementation | skill | as:skills/incremental-implementation | vendored | 0.6.13 | aeac41d | on `main`: line after Contract-First Slicing that calls `pickle:codebase-design` for Sketch First when a slice adds a module other code calls |
| skills/interview-me | skill | as:skills/interview-me | vendored | 0.6.13 | aeac41d | |
| skills/observability-and-instrumentation | skill | as:skills/observability-and-instrumentation | vendored | 0.6.13 | aeac41d | |
| skills/performance-optimization | skill | as:skills/performance-optimization | vendored | 0.6.13 | aeac41d | on `main`, from pstack's Perf issue playbook and explain-the-number principle: Step 1 and Step 4 point to `references/benchmark-checklist.md`, Step 1 writes the decision and noise floor before a run, Step 3 orders fixes cheapest first (the perf mantras), Step 4 names the limiter, and a Verification item |
| skills/planning-and-task-breakdown | skill | as:skills/planning-and-task-breakdown | vendored | 0.6.13 | aeac41d | on `main`: External tracker follows `docs/agents/issue-tracker.md` from `/pickle:setup`, and a local markdown tracker (`tasks/issues/`) keeps `tasks/todo.md`; Archiving a Plan keeps one active plan in `tasks/` and moves others to `tasks/archive/<date>-<slug>/`, restorable |
| skills/security-and-hardening | skill | as:skills/security-and-hardening | vendored | 0.6.13 | aeac41d | on `main`: the "just a prototype" rationalization row names `pickle:prototype` throwaways as the exception |
| skills/shipping-and-launch | skill | as:skills/shipping-and-launch | vendored | 0.6.13 | aeac41d | |
| skills/source-driven-development | skill | as:skills/source-driven-development | vendored | 0.6.13 | aeac41d | on `main`: Swift (`Package.swift`) detection and lockfile versions lines in Step 1, laravel.com and php.net in the source table, Step 2 reads `docs/agents/sources.md` from `/pickle:setup` |
| skills/spec-driven-development | skill | as:skills/spec-driven-development | vendored | 0.6.13 | aeac41d | on `main`: Code Style item names domain concepts from `GLOSSARY.md` and calls `pickle:domain-modeling`; Implement calls incremental-implementation and test-driven-development in the Skill tool form |
| skills/test-driven-development | skill | as:skills/test-driven-development | vendored | 0.6.13 | aeac41d | on `main`: line after Prefer Real Implementations Over Mocks that calls `pickle:codebase-design`; Parameterize Instead of Copying section after One Assertion Per Concept; the "just a prototype" rationalization row names `pickle:prototype` throwaways as the exception. Also on `main`, from pstack's `tdd` and test-behavior principle: Prove-It adds fail for the right reason, don't force a test, guardrails and the evidence report; Check Each Test Against Two Edits section and a Loose assertions anti-pattern row; Step 1 example asserts `expect.any(String)` instead of `toBeDefined()` |
| skills/pickle-mode | skill | as:skills/using-agent-skills | vendored | 0.6.13 | aeac41d | the entry skill, `/pickle:pickle-mode`. Renamed and user-only: `name: pickle-mode` and `disable-model-invocation: true` are set on `main`. Rewritten on `main` above Core Operating Behaviors: procedure, phase-ordered router with `pickle:` names, Shortcuts (question about code, bug fix, refactor, slow code, each with a reply line), Define entry for `pickle:prototype`, user-facing description. Upstream changes there conflict on merge. Also on `main`: Scope Discipline lets you delete code your own change made dead |
| commands/build.md | command | as:.claude/commands/build.md | vendored | 0.6.13 | aeac41d | on `main`: Default reads open items from the issue tracker when `tasks/plan.md` names one; ignores `tasks/archive/` and counts it as a planning artifact; every skill call in the Skill tool form |
| commands/code-simplify.md | command | as:.claude/commands/code-simplify.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form |
| commands/constraints.md | command | as:.claude/commands/constraints.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form; step 6 writes the pointer line in one instruction file |
| commands/plan.md | command | as:.claude/commands/plan.md | vendored | 0.6.13 | aeac41d | on `main`: task list goes to the task list target of `pickle:planning-and-task-breakdown`, not always `tasks/todo.md`; an unfinished plan can be archived to `tasks/archive/`; every skill call in the Skill tool form |
| commands/review.md | command | as:.claude/commands/review.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form; runs the Repo Lanes from `docs/agents/review.md` |
| commands/ship.md | command | as:.claude/commands/ship.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form; Phase B judges findings per `pickle:code-review-and-quality` Judging Reviewer Findings; Phase C template adds a Dismissed (with reason) list; Phase A adds the Repo Lanes from `docs/agents/review.md` and passes its Checks to `code-reviewer` and `security-auditor` |
| commands/spec.md | command | as:.claude/commands/spec.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form |
| commands/test.md | command | as:.claude/commands/test.md | vendored | 0.6.13 | aeac41d | on `main`: every skill call in the Skill tool form |
| commands/webperf.md | command | as:.claude/commands/webperf.md | vendored | 0.6.13 | aeac41d | |
| agents/code-reviewer.md | agent | as:agents/code-reviewer.md | vendored | 0.6.13 | aeac41d | |
| agents/security-auditor.md | agent | as:agents/security-auditor.md | vendored | 0.6.13 | aeac41d | |
| agents/test-engineer.md | agent | as:agents/test-engineer.md | vendored | 0.6.13 | aeac41d | |
| agents/web-performance-auditor.md | agent | as:agents/web-performance-auditor.md | vendored | 0.6.13 | aeac41d | on `main`: hands remediation to `pickle:performance-optimization` in the Skill tool form, not by its SKILL.md path |
| references | reference | as:references | vendored | 0.6.13 | aeac41d | checklists and patterns shared by several skills, commands and agents. On `main`: `testing-patterns.md` warns on truthiness matchers; `orchestration-patterns.md` adds Writing a subagent brief (pstack: orchestrate playbook's brief, minus TIMEBOX and STANDING, plus poteto-mode's Subagents ownership and fresh-agent rules; GOAL restates the user's goal and "Try one before many" from the Orchestrate rewrite) |
| docs/agents.md | doc | as:docs/agents.md | vendored | 0.6.13 | aeac41d | persona orchestration rules, linked from the vendored agents |
| docs/adoption-guide.md | doc | as:docs/adoption-guide.md | vendored | 0.6.13 | aeac41d | greenfield and brownfield rollout; on `main`: pickle install and pickle-mode wording, archiving a plan to `tasks/archive/` |
| evals/README.md | eval | as:evals/README.md | vendored | 0.6.13 | aeac41d | upstream's eval guide. Its Tier 1 to 3 and `run-evals.js` parts are not in pickle |
| evals/skill-impact.md | eval | as:evals/skill-impact.md | vendored | 0.6.13 | aeac41d | log of skill changes rejected on eval evidence |
| evals/plugin | eval | as:evals/plugin | vendored | 0.6.13 | aeac41d | firing evals: each skill fires on its own description, scored with and without pickle. On `main`: pickle adds its own cases beside upstream's, which are unchanged |

## Grafts

Sections a pickle file took from a source other than its row's. One row per file and source repo; the source uses the same prefixes as the row tables, comma-separated when several files fed the sections. Sections are heading texts, separated by `;`, each matching a heading in the file (`scripts/check-refs.sh` checks it, so a merge that renames or drops one fails). `scripts/upstream-diff.sh` diffs each source from its Commit. The row's Notes say what was taken.

| pickle item | Sections | Source | Commit |
|---|---|---|---|
| skills/technical-writing/SKILL.md | PR descriptions | skills/poteto-mode/playbooks/opening-a-pr.md | 23ab063 |
| skills/reflect/SKILL.md | 2. Review through three lenses | mp:skills/engineering/retro | 59db609 |
| skills/prototype/SKILL.md | 1. Name the decision; 2. Pick a branch; 4. Present the result | skills/poteto-mode/playbooks/prototype.md | 88d4751 |
| skills/code-review-and-quality/SKILL.md | Judging Reviewer Findings | skills/interrogate/SKILL.md | 23ab063 |
| skills/debugging-and-error-recovery/SKILL.md | Step 1: Reproduce; Step 2: Localize; Step 4: Fix the Root Cause; Step 5: Guard Against Recurrence; Safe Fallback Patterns | skills/poteto-mode/playbooks/bug-fix.md, skills/principle-fix-root-causes | 99743e9 |
| skills/deprecation-and-migration/SKILL.md | Internal APIs: Migrate and Delete in One Change | skills/principle-migrate-callers-then-delete-legacy-apis | 99743e9 |
| skills/git-workflow-and-versioning/SKILL.md | 4. Keep Concerns Separate | skills/principle-sequence-verifiable-units | 99743e9 |
| skills/performance-optimization/SKILL.md | Step 1: Measure; Step 3: Fix the Bottleneck; Step 4: Verify (Keep or Revert); Verification | skills/poteto-mode/playbooks/perf-issue.md, skills/principle-explain-the-number | 23ab063 |
| skills/test-driven-development/SKILL.md | The Prove-It Pattern (Bug Fixes); Check Each Test Against Two Edits; Test Anti-Patterns to Avoid | skills/tdd, skills/principle-test-behavior-not-implementation | 99743e9 |
| references/orchestration-patterns.md | Writing a subagent brief | skills/poteto-mode/playbooks/orchestrate.md, skills/poteto-mode/SKILL.md | 23ab063 |

## pickle skills

| pickle item | Kind | Source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| skills/audit-architecture | skill | - | new | n/a | - | user-only, from the maintainer's dotfiles. Rules at the top, every run a full audit, one Markdown report in `docs/agents/reports/`, Explore subagents with a set brief in batches of up to 12, one verifier instead of five audit passes, no `agents/openai.yaml`. Eval `audit-architecture-report` |

## Mods

| pickle item | Kind | Source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| hooks/register.tsx | mod | - | new | n/a | - | welcome band, task tip, review suggestion and `/pickle-guide` pane. Shapes from the `plugin-authoring` skill's examples. Tests in `tests/register.test.tsx` |

## Scripts

| pickle item | Kind | Source | Relation | Upstream version | Commit | Notes |
|---|---|---|---|---|---|---|
| scripts/upstream-diff.sh | script | - | new | n/a | - | maintainer only |
| scripts/vendor-sync.sh | script | - | new | n/a | - | maintainer only, refreshes `vendor/agent-skills` |
