---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (/pickle:constraints only exists with pickle). CLAUDE.md only imports AGENTS.md. The skill should write CONSTRAINTS.md and put its pointer line in AGENTS.md only.
expected_outcome: CONSTRAINTS.md exists; AGENTS.md has the "Read CONSTRAINTS.md" line; CLAUDE.md does not.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: "Non-interactive run: the user message is their only reply, so treat it as their answer to every question it covers."
---

/pickle:constraints Floor only for now, block on failures, measure and hold, 90 seconds. Don't install anything.
