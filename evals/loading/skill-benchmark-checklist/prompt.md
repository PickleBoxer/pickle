---
description: Skill. Asking whether a measured speedup holds up runs benchmark-checklist from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not run, edit or verify anything. Reply in a few lines."
---

I eager-loaded customers on the orders index and bench/orders.sh went from 840 ms to 95 ms in one run. Can I put "9x faster" in the PR?
