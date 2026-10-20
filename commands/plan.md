---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
argument-hint: "[feature-slug]"
---

Invoke the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`).

Find the feature folder (`.scratch/<feature-slug>/`) as `${CLAUDE_PLUGIN_ROOT}/references/feature-folder.md` describes, using the slug in `$ARGUMENTS` if given. Read its spec (`SPEC.md` or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to `plan.md` in the feature folder and record the task list in the task list target that the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`) defines (default `todo.md` in the feature folder).

If `plan.md` or `todo.md` already exists in the folder with unchecked tasks for different work, stop and ask before writing — never silently overwrite an incomplete plan.
