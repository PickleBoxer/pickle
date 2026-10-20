---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (setup is user-only). A Laravel 12 repo with Boost installed and a CLAUDE.md that holds Boost's guidelines block. Setup should record Boost search-docs as the first docs source with the versioned laravel.com URL as fallback, and put the Agent skills block outside the Boost block.
expected_outcome: docs/agents/sources.md names search-docs and laravel.com/docs/12.x; CLAUDE.md keeps the Boost block and has an Agent skills block outside it that points at docs/agents/sources.md.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: "Non-interactive run: the user message is their only reply, so treat it as their answer to every question it covers."
---

/pickle:setup Go with your recommended answers, don't seed the glossary, and skip the quality bar.
