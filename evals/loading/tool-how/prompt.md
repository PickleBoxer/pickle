---
description: Tool. A how-does-it-work question runs the how tool from the investigate playbook.
tags: [loading, tools]
runs: 1
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Tool eval dry run. Follow pickle-mode exactly as you would for real until your first call to a pickle tool skill returns. Then stop: do not edit, delegate further or verify. Reply in a few lines and end with the Loaded line."
---

/pickle:pickle-mode How does an order get shipped in this app? Walk me through the flow. Don't change anything.
