---
description: A loading eval dry run. A multi-part feature with no spec and open requirements, started through pickle-mode, so it is non-trivial. The router should start at spec-driven-development, before the build skills, called by full pickle:-prefixed names.
expected_outcome: pickle:spec-driven-development is loaded, and before pickle:incremental-implementation.
max_turns: 4
allowed_tools: [Skill]
append_system_prompt: "Dry run: call the Skill tool once for each skill you would use for the task, in order, then stop and list them. Don't read, write or run anything else."
---

/pickle:pickle-mode Add status tracking to orders: an OrderStatus enum, rules for which status changes are allowed, a migration for existing orders, and an API endpoint to change an order's status.
