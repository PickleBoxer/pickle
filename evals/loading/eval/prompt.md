---
description: Loading. Comparing two prompts is an eval.
tags: [loading, extended]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Compare the two prompts for the order summary email, `prompts/summary-a.md` and `prompts/summary-b.md`, and tell me which one is better.
