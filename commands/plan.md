---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`).

`$ARGUMENTS` may name a tracker issue (key or URL) or a work folder slug (`docs/work/<slug>/`). Read the existing spec (SPEC.md or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to tasks/plan.md (or the work folder) and record the task list in the task list target that the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`) defines (default tasks/todo.md).

If tasks/plan.md or tasks/todo.md already exists with unchecked tasks for different work, stop and ask before writing: finish it, discard it, or archive it to `docs/work/archive/` as the skill's Work Folder describes. Never silently overwrite an incomplete plan.
