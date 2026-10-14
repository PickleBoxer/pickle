---
description: Loading. A multi-PR migration plan with a concurrent writer.
tags: [loading, extended, no-code]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Plan how to move orders from the legacy `orders` table to the new `shop_orders` schema over several PRs. The old admin app keeps writing to `orders` during the move. I only want the plan, no code.
