---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (setup is user-only). A PHP repo on GitHub with one architecture test. Setup should write the general boundaries guide from its template, without naming this repo's tests, and point the Agent skills block at it.
expected_outcome: docs/agents/boundaries.md exists, holds the override form and does not name ShopOrdersArchTest; the Agent skills block in CLAUDE.md points at docs/agents/boundaries.md.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: "Non-interactive run: the user message is their only reply, so treat it as their answer to every question it covers."
---

/pickle:setup Go with your recommended answers, don't seed the glossary, and skip the quality bar.
