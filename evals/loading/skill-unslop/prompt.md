---
description: Skill. Asking to clean AI-sounding prose runs unslop from its description, without pickle-mode.
tags: [loading, skills]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Skill eval dry run. Work as you would for real until your first Skill call returns. Then stop: do not edit or verify. Reply in a few lines."
---

docs/release-notes.md reads like a chatbot wrote it. Clean up the writing before we publish.
