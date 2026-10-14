---
description: Skill. Asking for a how-to doc runs technical-writing from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not write files or verify. Reply in a few lines."
---

Write docs/shipping.md for the support team: how to ship an order by hand when the automatic shipping fails.
