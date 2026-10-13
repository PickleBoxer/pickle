---
description: Loading. An enum replacing string states is a feature task.
tags: [loading, core]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode The `orders.status` column holds the strings `pending`, `paid` and `shipped`. Add a backed `OrderStatus` enum, cast `Order::$status` to it, and replace the string comparisons in the app with the enum.
