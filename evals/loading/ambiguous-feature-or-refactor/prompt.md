---
description: Loading. New enum plus cleanup. Either playbook is fine.
tags: [loading, ambiguous]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Add a status enum to orders and clean up the Order model while you're there.
