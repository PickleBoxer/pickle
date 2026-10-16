---
description: A loading eval dry run. A bug fix started through pickle-mode. The router's bug fix line should load debugging-and-error-recovery, then test-driven-development, called by full pickle:-prefixed names.
expected_outcome: pickle:debugging-and-error-recovery is loaded before pickle:test-driven-development.
max_turns: 4
allowed_tools: [Skill]
append_system_prompt: "Dry run: call the Skill tool once for each skill you would use for the task, in order, then stop and list them. Don't read, write or run anything else."
---

/pickle:pickle-mode Fix this bug: splitCents(100, 3) returns [33, 33, 33] and a cent goes missing.
