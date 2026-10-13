---
description: Loading. A wrong total with a known symptom is a bug fix.
tags: [loading, core]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Order totals are wrong: `Order::total()` still counts refunded lines. Fix it.
