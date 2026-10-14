---
description: Language. A feature in a Laravel project loads the project's conventions, then the installed laravel-best-practices from the profile.
tags: [loading, language]
runs: 1
max_turns: 14
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Add order cancellation. A pending or paid order can be cancelled, a shipped one cannot, and a cancelled order must never ship.
