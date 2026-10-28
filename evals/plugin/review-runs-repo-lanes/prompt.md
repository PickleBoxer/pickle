---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash (the review command needs pickle; Bash reads the diff). A repo whose docs/agents/review.md lists a TypeScript lane on an installed skill, a PHP lane on a skill that is not installed, and one check. The review should run the TypeScript lane as a subagent, name the PHP lane as skipped, report the check breach, and change no file.
expected_outcome: An Agent call for the TypeScript lane; the reply names acme-php-guidelines as skipped and reports the logged customer email as a breach of the repo's check; no Edit or Write.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/pickle:review my uncommitted changes
