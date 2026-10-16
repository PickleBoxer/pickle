---
description: A loading eval dry run. A deploy request started through pickle-mode. The router's Ship phase should load shipping-and-launch, called by its full pickle:-prefixed name.
expected_outcome: pickle:shipping-and-launch is loaded with the Skill tool.
max_turns: 4
allowed_tools: [Skill]
---

/pickle:pickle-mode Deploy this to production.

Dry run: load the skills you would use for this task, in order, then stop and list them. Don't read, write or run anything.
