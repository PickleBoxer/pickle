---
name: pickle-mode
description: Runs a coding task through the full pickle process, reading only the playbooks and loading only the principles the task needs. Use when the user runs /pickle:pickle-mode.
argument-hint: "<task>"
disable-model-invocation: true
---

# pickle mode

Stub for the eval smoke test. Only the feature playbook and three principles exist.

## Process

1. Read `.claude/pickle.md` in the project. It holds the verify commands and gates. If it is missing, use generic defaults and suggest `/pickle:setup`.
2. Pick the playbooks that fit the task from the index below and read them. Usually one. If it is unclear, ask once.
3. Copy the playbook steps into the todo list.
4. Load a principle with the Skill tool, by name (`pickle:principle-<name>`), whenever a playbook step or the index below names one that applies. Never read a principle file directly.
5. Run the steps. Verify with the profile commands.
6. End the reply with one line: `Loaded: <playbooks>, <principles>`.

## Non-negotiables

- Any code: name the data shape first, per **principle-model-the-domain**.

## Playbooks

Paths are relative to this file.

- `playbooks/feature.md`: add or change behaviour.

## Principles

Load the skill by name before applying it. In the reply, name each principle that changed a decision and how. Cite only principles loaded this session.

- **principle-model-the-domain**: stateful or branch-heavy logic, or the same shape check repeated across files.
- **principle-types**: designing types or signatures. Make illegal states unrepresentable.
- **principle-finish-migrations**: a new API or representation while old callers exist. Migrate every caller and delete the old one in the same change.
