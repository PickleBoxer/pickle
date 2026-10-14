---
description: Skill. Asking to clean up AI-written code on a branch runs deslop from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not edit, delegate or verify. Reply in a few lines."
---

An agent wrote the fix on this branch and the code is padded with junk it didn't need. Clean it up before I commit.
