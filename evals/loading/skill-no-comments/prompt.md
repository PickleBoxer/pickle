---
description: Skill. Asking to strip comments from a branch before review runs no-comments from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not edit, delegate or verify. Reply in a few lines."
---

Before I ask for review, get rid of the noisy comments in the change on this branch.
