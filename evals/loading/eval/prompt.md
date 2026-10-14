---
description: Loading. Comparing two prompts is an eval.
tags: [loading, extended, no-code]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Compare the two prompts for the order summary email, `prompts/summary-a.md` and `prompts/summary-b.md`, and tell me which one is better.
