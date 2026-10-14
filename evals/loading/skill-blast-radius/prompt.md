---
description: Skill. Asking what a small branch could break runs blast-radius from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not run, edit or verify anything. Reply in a few lines."
---

The sync-batch-250 branch is a one-line change and I want to merge it today. What could it break?
