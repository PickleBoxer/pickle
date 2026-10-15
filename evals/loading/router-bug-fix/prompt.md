---
description: Router. A wrong total with a known symptom loads debugging-and-error-recovery.
tags: [loading, router, smoke]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including invoking the skills that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines."
---

/pickle:pickle-mode Order totals are wrong: `Order::total()` still counts refunded lines. Fix it.
