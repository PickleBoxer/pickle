---
name: pickle-mode
description: Runs a coding task through the full pickle process, reading only the playbooks and loading only the principles the task needs. Use when the user runs /pickle:pickle-mode.
argument-hint: "<task>"
disable-model-invocation: true
metadata:
  upstream: pstack/skills/poteto-mode/SKILL.md
  upstream-version: 0.15.24
---

# pickle mode

Run the task through the full process below. Playbooks and principles are files next to this one, and paths below are relative to this file. Read a file only when the task needs it.

Mentions in this skill, its playbooks and its principles:

- ``the **<name>** skill (Skill tool, `pickle:<name>`)``: call that skill with the Skill tool. When pickle is installed without the plugin, the name is `<name>`.
- `**principle-<name>**`: the file `principles/<name>.md`. Read it with Read.
- `pickle:<name>` as a subagent type: an agent. Start it with the Agent tool.

## Process

1. Read `.claude/pickle.md` in the project with Read. It holds the stack, the verify commands and the gates. If it is missing, use the project's obvious test and lint commands and suggest `/pickle:setup` once in the reply.
   - Load every convention the profile lists under `conventions:` before step 2: read a file path with Read, invoke a skill name with the Skill tool. Always, also for tasks that write no code (investigating, reading a trace, planning): conventions name the project's tools, commands and failure modes those tasks rely on.
2. Pick the playbooks that fit the task from the playbook index and read them. Usually one. Two when the task has two parts, for example feature, then opening-a-pr. If two playbooks fit equally and the choice changes the work, ask once with `AskUserQuestion`, recommended playbook first. Otherwise state the choice and go. If no playbook fits, or the work is a large cross-cutting migration the user will review after stepping away, run the **figure-it-out** skill (Skill tool, `pickle:figure-it-out`) instead of forcing one.
3. Copy the playbook steps into the todo list, one todo per step. Mark a skipped step `skip: <reason>`, never drop it silently.
4. Read principles.
   - Every principle a chosen playbook names: always, right after reading the playbook, before its first step. Playbook mentions are not optional.
   - Every principle a non-negotiable names, when the non-negotiable applies.
   - Any other principle whose trigger in the principle index fits the task.
5. Name the principle file, and the convention file or skill for code todos, in the todo items they shape. Before starting a todo, if a file it names is no longer in context (for example after compaction), read it again.
6. Run the steps. Use the tools a playbook lists, in its order. A playbook may skip a tool, and says when.
   - `how`: the **how** skill (Skill tool, `pickle:how`). Pass the question and why it matters.
   - `why`: the **why** skill (Skill tool, `pickle:why`). Pass the question and the target. It searches git and every connected MCP source.
   - `architect`: the **architect** skill (Skill tool, `pickle:architect`). Pass the design task, the constraints and the how findings. Add `with sign-off` when the user wants to approve the design before code.
   - Implementer subagent: the `pickle:pickle-implementer` agent. Pass the files, the data shape, the success check and the verify commands.
   - `interrogate`: the **interrogate** skill (Skill tool, `pickle:interrogate`). Pass what the change is for and the base branch. Add `panel` when the playbook says so or the user asks for it.
   - `swarm`: the **swarm** skill (Skill tool, `pickle:swarm`). Pass the done predicate, N and the shape.
   - When a tool returns a question for the user (`Intent unclear:`, `Done predicate unclear:`, a `Sign-off:` line), ask it with `AskUserQuestion` and run the tool again with the answer. When swarm returns `Use /batch:`, give the user that command. When it returns `Cannot fan out:`, start its briefs yourself with the Agent tool, `isolation: "worktree"`.
   - If a tool or agent is not installed, use Claude Code's own: `Explore` for how, `general-purpose` told to change nothing for why, `Plan` for architect, `general-purpose` for the implementer and for interrogate.
7. Tools and subagents do not see this conversation. Give each one everything it needs, including the absolute paths of the principle files and convention files that apply and the convention skills to load, and tell it to read them first.
8. Verify with the profile's verify commands. Fix and rerun until they pass, or report exactly what still fails.
9. End the reply with one line: `Loaded: <playbooks>, <principles>, <conventions>`.

## Non-negotiables

- Any code: name the data shape before writing logic, per **principle-model-the-domain**.
- Before saying done, or reporting a number: show direct evidence, per **principle-prove-it-works**.
- A gate in the profile means stop and ask before that action, even when the playbook says to proceed.
- Apply each principle with the project's own language, framework and tools. The project defines them in `CLAUDE.md`, in its conventions and in its existing code. Follow those over any default you know. When the project says nothing, use the language's standard idioms and say which you chose.
- The project's `CLAUDE.md`, its conventions and the user's instructions win over a playbook or principle when they conflict. Say which rule you followed.
- `interrogate` with `panel`, and `swarm`, run only when a playbook calls for them or the user names them.

## Playbooks

Core:

- `playbooks/feature.md`: add or change behaviour a user or caller can observe.
- `playbooks/bug-fix.md`: something is broken, the symptom is known, and the task is to fix it.
- `playbooks/refactor.md`: change the structure, keep the behaviour identical.
- `playbooks/investigate.md`: explain how or why something behaves, or recommend between options. Read-only: no code changes, even when the cause is a bug.
- `playbooks/perf.md`: make a known slow or costly path faster or cheaper. A target number chased over many iterations is hillclimb.
- `playbooks/prototype.md`: try one or more throwaway versions so the user can pick a direction. The real build afterwards is feature.
- `playbooks/opening-a-pr.md`: turn the current branch into a reviewable pull request, alone or after another playbook.
- `playbooks/session-pickup.md`: resume work an earlier session left behind, from a handoff note, a branch or a transcript.
- `playbooks/pause-safely.md`: stop mid-task and leave the work resumable. Only when the user asks to stop. "Keep going" is not a pause.

Extended (experimental, ported from pstack):

- `playbooks/hillclimb.md`: push a measurable number toward a target over many measured iterations, such as build time, test time, bundle size or memory: "bring X down to Y", "keep at it until it hits the target".
- `playbooks/eval.md`: compare prompts, models or skills and judge which does better: "A or B?", "is the new version an improvement".
- `playbooks/autonomous-run.md`: keep working unattended until a pass or fail condition is met: "carry on without me", "work until it's green", "no need to check in". Read it together with the playbook for the work itself, often bug-fix. A number pushed toward a target is hillclimb.
- `playbooks/babysit.md`: get an open pull request to mergeable: red checks, failed builds or review comments on the PR.
- `playbooks/multi-phase-plan.md`: plan a change that ships over several PRs or deploys, such as a schema or service migration with both versions live. The deliverable is the plan, not the change.
- `playbooks/worktree-cleanup.md`: remove stale git worktrees and branches safely.
- `playbooks/runtime-forensics.md`: diagnose a live process that misbehaves now: CPU, memory, hangs. Not a captured trace.
- `playbooks/trace-forensics.md`: analyse a captured profile, trace or log file. Not a live process.
- `playbooks/visual-parity.md`: change how a UI is built while the rendered result stays identical: a component or design-system migration, a CSS rewrite, a framework swap with no visible change.
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
- **principle-idempotent-operations** (`principles/idempotent-operations.md`): jobs, commands, webhooks, migrations, retries, schedulers, startup or cleanup code, or anything that can crash or run twice. Also a symptom of something happening twice: duplicate rows, emails, payments or job runs.
- **principle-finish-migrations** (`principles/finish-migrations.md`): a new API, type or format while old callers exist, or a planned rewrite or migration.
- **principle-no-shared-writes** (`principles/no-shared-writes.md`): two processes, workers, apps, agents or branches that might write the same row, file or key, or a design that calls for a lock.

Verification:

- **principle-prove-it-works** (`principles/prove-it-works.md`): before declaring done, or before trusting, reporting or acting on a number, benchmark or test result.
- **principle-fix-root-causes** (`principles/fix-root-causes.md`): debugging, wrong behaviour or failing CI, or a fix about to hide a symptom with a guard, retry or workaround. Reproduce first, find the cause before the fix.
- **principle-small-verified-steps** (`principles/small-verified-steps.md`): multi-step or multi-file work, sweeps, migrations, or planning commits and PRs.
- **principle-test-behavior** (`principles/test-behavior.md`): writing, changing, reviewing or keeping a test, including a failing test that reproduces a bug.

Delegation:

- **principle-guard-the-context** (`principles/guard-the-context.md`): large files, logs, traces or transcripts, fan-out, resuming or pausing a session, or a filling context.
