---
description: Skill. Asking for a reviewable decision trail on unattended work runs show-me-your-work from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not run, edit or verify anything. Reply in a few lines."
---

I'm stepping away for the afternoon. Move the order status strings in app/Models/Order.php to an enum, and keep a decision log of every call you make so I can audit it when I'm back.
