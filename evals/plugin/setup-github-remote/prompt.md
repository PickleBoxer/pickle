---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (setup is user-only). A GitHub remote and an existing CLAUDE.md. Setup should propose GitHub, write the two docs/agents files and add the Agent skills block to CLAUDE.md, with no triage labels.
expected_outcome: docs/agents/issue-tracker.md (GitHub, gh), docs/agents/domain.md, and an Agent skills block in CLAUDE.md; no AGENTS.md and no triage-labels.md.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: "Non-interactive run: the user message is their only reply, so treat it as their answer to every question it covers."
---

/pickle:setup Go with your recommended answers, don't seed the glossary, and skip the quality bar.
