---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash (correct is user-only). A TypeScript repo whose history shows routes importing the db client directly twice, each fixed afterwards, although AGENTS.md forbids it, plus a one-off typo fix. Correct must mine the history, report the db import as a class with both instances, pick a level above docs, and stop for approval.
expected_outcome: git log runs; no Edit or Write; the reply names the routes-import-db class with both fix commits as evidence, picks architecture or a lint or CI check (not a docs line), does not count the one-off typo as a class, and asks which classes to fix.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

/pickle:correct
