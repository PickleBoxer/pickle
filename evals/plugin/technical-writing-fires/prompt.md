---
description: A request to write a short how-to for a script. The technical-writing skill should fire and the doc should follow its how-to mode.
expected_outcome: A how-to titled by the task, with numbered command steps, the condition before the instruction, code in code font, and no background digressions.
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Write a short doc for our repo on lowering the import budget. The script is `scripts/budget.mjs`. It reads the committed limit from `budget.json` and counts files that import protos; CI fails if the count is over the limit. `node scripts/budget.mjs --write` rewrites `budget.json` with the current count, and it should only be used to lower the limit, never to raise it.
