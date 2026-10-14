---
description: Skill. A bug fix runs tdd for the failing test before how or any other skill.
tags: [loading, skills]
runs: 1
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Follow pickle-mode exactly as you would for real until your first call to a pickle skill returns. Then stop: do not write files, delegate or verify. Reply in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Order totals are wrong: `Order::total()` still counts refunded lines. Fix it.
