---
description: Tool. A why-is-it-this-way question runs the why tool from its description, not how, without pickle-mode.
tags: [loading, tools]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Tool eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not edit, delegate further or verify. Reply in a few lines."
---

Why does SyncOrders only send 100 orders per request? It looks like an arbitrary limit and I want to know the reason before I raise it.
