---
description: Loading. Iterating on one metric toward a target.
tags: [loading, extended]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Get the test suite under 30 seconds. It takes about 3 minutes now. Keep iterating until it's under.
