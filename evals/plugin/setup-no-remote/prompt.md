---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (setup is user-only). No remote and no instruction file. Setup should propose local markdown and ask which instruction file to create instead of picking one.
expected_outcome: docs/agents/issue-tracker.md points at tasks/issues/; neither CLAUDE.md nor AGENTS.md is created; the reply asks which one to create.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: "Non-interactive run: the user message is their only reply, so treat it as their answer to every question it covers."
---

/pickle:setup Go with your recommended answers, don't seed the glossary, and skip the quality bar.
