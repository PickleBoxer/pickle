---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash (reflect is user-only). Reviews a fixture transcript where the user corrected a console.log twice and the agent ran the wrong test command three times. Reflect must digest it with its script, route the mechanical finding to a check rather than prose, and stop for approval.
expected_outcome: digest.sh runs on .scratch/session.jsonl; no Edit or Write; the reply's Accepted table routes console.log to a lint rule, hook or CI check, flags the missing guardrail or the test command, and asks which rows to apply.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/pickle:reflect .scratch/session.jsonl
