---
description: A loading eval dry run. A deploy request started through pickle-mode. The router's Ship phase should load shipping-and-launch, called by its full pickle:-prefixed name.
expected_outcome: pickle:shipping-and-launch is loaded with the Skill tool.
max_turns: 4
allowed_tools: [Skill]
append_system_prompt: "Dry run: call the Skill tool once for each skill you would use for the task, in order, then stop and list them. Don't read, write or run anything else."
---

/pickle:pickle-mode Deploy this to production.
