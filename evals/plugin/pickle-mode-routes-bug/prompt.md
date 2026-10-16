---
description: A loading eval dry run. A bug fix started through pickle-mode. The router's bug fix line should load debugging-and-error-recovery, then test-driven-development, called by full pickle:-prefixed names.
expected_outcome: pickle:debugging-and-error-recovery is loaded before pickle:test-driven-development.
max_turns: 4
allowed_tools: [Skill]
---

/pickle:pickle-mode Fix this bug: splitCents(100, 3) returns [33, 33, 33] and a cent goes missing.

Dry run: load the skills you would use for this task, in order, then stop and list them. Don't read, write or run anything.
