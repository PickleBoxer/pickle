---
description: Loading. Moving Stripe behind an interface with no behaviour change is a refactor.
tags: [loading, core]
runs: 1
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, AskUserQuestion]
---

/pickle:pickle-mode Extract the Stripe calls in `CheckoutController` behind a `PaymentGateway` interface, so we can add a second provider later. Behaviour must not change.
