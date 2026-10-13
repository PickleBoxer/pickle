---
description: Loading. Diagnosing from an existing capture.
tags: [loading, extended]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Here is a CPU profile captured in production: `storage/profiles/checkout.cpuprofile`. What is slow?
