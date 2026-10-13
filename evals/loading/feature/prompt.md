---
description: Loading. New behaviour (cancellation) on a stateful model is a feature task.
tags: [loading, core, smoke]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Add order cancellation. A pending or paid order can be cancelled, a shipped one cannot, and a cancelled order must never ship.
