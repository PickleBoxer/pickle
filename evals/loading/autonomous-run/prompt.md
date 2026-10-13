---
description: Loading. Driving to a checkable exit condition without stopping.
tags: [loading, extended]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Keep fixing until all tests pass. Don't stop to ask me.
