---
description: Loading. A query count problem on one page is a perf task.
tags: [loading, core]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode The orders index page runs about 200 queries per request. Make it fast.
