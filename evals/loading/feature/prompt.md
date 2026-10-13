---
description: Loading. An enum replacing string states is a feature task.
tags: [loading, core, smoke]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode The `orders.status` column holds the strings `pending`, `paid` and `shipped`. Add a backed `OrderStatus` enum, cast `Order::$status` to it, and replace the string comparisons in the app with the enum.
