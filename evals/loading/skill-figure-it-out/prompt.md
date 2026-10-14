---
description: Skill. A large cross-cutting migration the user reviews later routes from pickle-mode to figure-it-out, not straight into refactor's how step.
tags: [loading, skills]
runs: 1
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Follow pickle-mode exactly as you would for real until your first call to a pickle skill returns. Then stop: do not write files, delegate or verify. Reply in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Replace every raw order status string ('pending', 'paid', 'shipped', 'refunded') across the app with an OrderStatus enum: models, controllers, jobs, migrations, tests, everywhere. It's a big one and I'm away until tomorrow, so work through it and leave me something I can audit.
