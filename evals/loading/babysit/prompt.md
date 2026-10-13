---
description: Loading. Getting an open PR to green.
tags: [loading, extended]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Get my PR green. CI is failing on it. The last CI log is in `ci-log.txt`.
