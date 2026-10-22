---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash Write (the skill is user-only). A first run on a repo with no earlier audit. src/orders keeps an Order's status in booleans that allow invalid combinations, src/notify repeats one switch on channel in three files, src/reports looks customers up with a linear find inside loops, and src/format is fine. The skill should review each subsystem with Explore subagents, write one Markdown report to .scratch/reports/, change no other file and ask nothing.
expected_outcome: At least one Explore subagent; an audit-architecture-*.md written; no Edit and no git command that changes the repo; the reply gives the report path, a finding each for orders, notify and reports, a skip for format, and IDs grouped into P0 to P3, and ends without a question.
max_turns: 50
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write]
---

/pickle:audit-architecture
