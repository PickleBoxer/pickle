---
description: Tool. Challenging a design from more than one angle runs interrogate with panel, without pickle-mode.
tags: [loading, tools]
runs: 1
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Tool eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not edit, delegate further or verify. Reply in a few lines."
---

I'm not convinced by the design of the order cancellation on this branch. Challenge it from more than one angle before I merge it.
