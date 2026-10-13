---
name: pickle-mode
description: Runs a coding task through the full pickle process, reading only the playbooks and loading only the principles the task needs. Use when the user runs /pickle:pickle-mode.
argument-hint: "<task>"
disable-model-invocation: true
---

# pickle mode

Run the task through the full process below. Playbooks and principles are files next to this one, and paths below are relative to this file. Read a file only when the task needs it.

## Process

1. Read `.claude/pickle.md` in the project with Read. It holds the stack, the verify commands and the gates. If it is missing, use the project's obvious test and lint commands and suggest `/pickle:setup` once in the reply.
2. Pick the playbooks that fit the task from the playbook index and read them. Usually one. Two when the task has two parts, for example feature, then opening-a-pr. If two playbooks fit equally and the choice changes the work, ask once with `AskUserQuestion`, recommended playbook first. Otherwise state the choice and go.
3. Copy the playbook steps into the todo list, one todo per step. Mark a skipped step `skip: <reason>`, never drop it silently.
4. Read principles. **principle-<name>** is the file `principles/<name>.md`.
   - Every principle a chosen playbook names: always, right after reading the playbook, before its first step. Playbook mentions are not optional.
   - Every principle a non-negotiable names, when the non-negotiable applies.
   - Any other principle whose trigger in the principle index fits the task.
5. Name the principle file in the todo items it shapes. Before starting a todo, if a principle it names is no longer in context (for example after compaction), read it again.
6. Run the steps. Use the tools a playbook lists, in its order: `explore`, `design-options`, an implementer subagent, `review`. A playbook may skip a tool, and says when.
7. When delegating to a subagent, give it the absolute paths of the principle files that apply and tell it to read them first.
8. Verify with the profile's verify commands. Fix and rerun until they pass, or report exactly what still fails.
9. End the reply with one line: `Loaded: <playbooks>, <principles>`.

## Non-negotiables

- Any code: name the data shape before writing logic, per **principle-model-the-domain**.
- Before saying done, or reporting a number: show direct evidence, per **principle-prove-it-works**.
- A gate in the profile means stop and ask before that action, even when the playbook says to proceed.
- The project's `CLAUDE.md` and the user's instructions win over a playbook when they conflict. Say which rule you followed.
- `bakeoff` and `adversarial-review` run only when the user names them.

## Playbooks

Core:

- `playbooks/feature.md`: add or change behaviour a user or caller can observe.
- `playbooks/bug-fix.md`: something is broken and the symptom is known. Fix it.
- `playbooks/refactor.md`: change the structure, keep the behaviour identical.
- `playbooks/investigate.md`: explain how or why something behaves. Answer, do not change code.
- `playbooks/perf.md`: make a known slow or costly path faster or cheaper.
- `playbooks/prototype.md`: try one or more throwaway versions to decide a direction before building it.
- `playbooks/opening-a-pr.md`: turn the current branch into a reviewable pull request.
- `playbooks/session-pickup.md`: resume work an earlier session left behind.
- `playbooks/pause-safely.md`: stop mid-task and leave the work resumable.

Extended (experimental, ported from pstack):

- `playbooks/hillclimb.md`: push a measurable number toward a target over many measured iterations.
- `playbooks/eval.md`: compare prompts, models or skills with an eval.
- `playbooks/autonomous-run.md`: keep working unattended until a stop condition is met.
- `playbooks/babysit.md`: get an open pull request green: failing CI and review comments.
- `playbooks/multi-phase-plan.md`: plan a change that ships over several PRs or deploys.
- `playbooks/worktree-cleanup.md`: remove stale git worktrees and branches safely.
- `playbooks/runtime-forensics.md`: diagnose a live process that misbehaves now: CPU, memory, hangs.
- `playbooks/trace-forensics.md`: analyse a captured profile, trace or log file.
- `playbooks/visual-parity.md`: change how a UI is built while the rendered result stays identical.
- `playbooks/authoring-a-skill.md`: write or change a skill, playbook or agent prompt.

## Principles

Read the file before applying a principle. In the reply, name each principle that changed a decision and how. Cite only principles read this session.

Core:

- **principle-laziness** (`principles/laziness.md`): sizing or sequencing a change, or tempted to add an abstraction, layer, option or guard the task did not ask for.
- **principle-model-the-domain** (`principles/model-the-domain.md`): stateful logic, a new branch in an if/else chain, or the same shape check repeated across files.
- **principle-redesign-from-first-principles** (`principles/redesign-from-first-principles.md`): integrating a new requirement, provider or variant into an existing design, or a change that only fits with special cases.
- **principle-minimize-reader-load** (`principles/minimize-reader-load.md`): code that is hard to follow, a new wrapper, adapter or piece of state, or prose another reader must read, such as a PR description or a skill.

Architecture:

- **principle-boundaries** (`principles/boundaries.md`): framework code, controllers, adapters, third-party APIs, parsing input, or deciding where a check or error handler belongs.
- **principle-types** (`principles/types.md`): designing types, signatures, enums or casts, or a runtime or null check that hints a type is too weak. Make illegal states unrepresentable.
- **principle-idempotent-operations** (`principles/idempotent-operations.md`): jobs, commands, webhooks, migrations, retries, schedulers, startup or cleanup code, or anything that can crash or run twice.
- **principle-finish-migrations** (`principles/finish-migrations.md`): a new API, type or format while old callers exist, or a planned rewrite or migration.
- **principle-no-shared-writes** (`principles/no-shared-writes.md`): two processes, workers, apps, agents or branches that might write the same row, file or key, or a design that calls for a lock.

Verification:

- **principle-prove-it-works** (`principles/prove-it-works.md`): before declaring done, or before trusting, reporting or acting on a number, benchmark or test result.
- **principle-fix-root-causes** (`principles/fix-root-causes.md`): debugging, wrong behaviour or failing CI, or a fix about to hide a symptom with a guard, retry or workaround. Reproduce first, find the cause before the fix.
- **principle-small-verified-steps** (`principles/small-verified-steps.md`): multi-step or multi-file work, sweeps, migrations, or planning commits and PRs.
- **principle-test-behavior** (`principles/test-behavior.md`): writing, changing, reviewing or keeping a test, including a failing test that reproduces a bug.

Delegation:

- **principle-guard-the-context** (`principles/guard-the-context.md`): large files, logs, traces or transcripts, fan-out, resuming or pausing a session, or a filling context.
