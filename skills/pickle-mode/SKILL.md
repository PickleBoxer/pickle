---
name: pickle-mode
description: Runs a coding task through the full pickle process, reading only the playbooks and loading only the principles the task needs. Use when the user runs /pickle:pickle-mode.
argument-hint: "<task>"
disable-model-invocation: true
---

# pickle mode

Stub for the eval smoke test. Only three playbooks exist. All 14 principles exist.

Playbooks and principles are files next to this one. Paths below are relative to this file. Read a file only when the task needs it.

## Process

1. Read `.claude/pickle.md` in the project. It holds the verify commands and gates. If it is missing, use generic defaults and suggest `/pickle:setup`.
2. Pick the playbooks that fit the task from the index below and read them. Usually one. If it is unclear, ask once.
3. Copy the playbook steps into the todo list.
4. Read a principle whenever a playbook step, a non-negotiable or the index below names one that applies. **principle-<name>** is the file `principles/<name>.md`. Read it in full before applying it.
5. Name the principle file in the todo items it shapes. Before starting a todo, if a principle it names is no longer in context (for example after compaction), read it again.
6. When delegating to a subagent, give it the absolute paths of the principle files that apply and tell it to read them.
7. Run the steps. Verify with the profile commands.
8. End the reply with one line: `Loaded: <playbooks>, <principles>`.

## Non-negotiables

- Any code: name the data shape first, per **principle-model-the-domain**.

## Playbooks

- `playbooks/feature.md`: add or change behaviour.
- `playbooks/bug-fix.md`: something is broken and the symptom is known.
- `playbooks/refactor.md`: change the structure, keep the behaviour.

## Principles

Read the file before applying a principle. In the reply, name each principle that changed a decision and how. Cite only principles read this session.

- **principle-laziness** (`principles/laziness.md`): sizing a change, or tempted to add an abstraction, layer, option or guard the task did not ask for.
- **principle-model-the-domain** (`principles/model-the-domain.md`): stateful or branch-heavy logic, or the same shape check repeated across files.
- **principle-redesign-from-first-principles** (`principles/redesign-from-first-principles.md`): integrating a new requirement into an existing design.
- **principle-minimize-reader-load** (`principles/minimize-reader-load.md`): code that is hard to follow, a new wrapper or piece of state, or prose another reader must read.
- **principle-boundaries** (`principles/boundaries.md`): validation, error handling, framework adapters or third-party services.
- **principle-types** (`principles/types.md`): designing types or signatures. Make illegal states unrepresentable.
- **principle-idempotent-operations** (`principles/idempotent-operations.md`): jobs, commands, retries or anything that can crash or run twice.
- **principle-finish-migrations** (`principles/finish-migrations.md`): a new API or representation while old callers exist, or a planned migration.
- **principle-no-shared-writes** (`principles/no-shared-writes.md`): two actors that might write the same state, or a design that calls for a lock.
- **principle-prove-it-works** (`principles/prove-it-works.md`): before declaring done, or before trusting or reporting a number.
- **principle-fix-root-causes** (`principles/fix-root-causes.md`): debugging. Reproduce first, find the cause before the fix.
- **principle-small-verified-steps** (`principles/small-verified-steps.md`): multi-step work, sweeps, migrations, or planning commits and PRs.
- **principle-test-behavior** (`principles/test-behavior.md`): writing, changing or keeping a test.
- **principle-guard-the-context** (`principles/guard-the-context.md`): large files, logs or traces, fan-out, or resuming and pausing a session.
