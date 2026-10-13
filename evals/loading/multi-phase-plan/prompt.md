---
description: Loading. A multi-PR migration plan with a concurrent writer.
tags: [loading, extended]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Plan how to move orders from the legacy `orders` table to the new `shop_orders` schema over several PRs. The old admin app keeps writing to `orders` during the move. I only want the plan, no code.
