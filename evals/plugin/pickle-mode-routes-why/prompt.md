---
description: A loading eval dry run. A change to unfamiliar code that starts with a why question, started through pickle-mode. The router's Build line for why should load the why skill by its full pickle:-prefixed name.
expected_outcome: pickle:why is loaded.
max_turns: 4
allowed_tools: [Skill]
append_system_prompt: "Dry run: call the Skill tool once for each skill you would use for the task, in order, then stop and list them. Don't read, write or run anything else."
---

/pickle:pickle-mode The retry limit in src/payments/client.ts is hard-coded to 5. Before I raise it to 10, find out why it was set to 5 and whether that reason still holds.
