---
description: Loading. Moving Stripe behind an interface with no behaviour change is a refactor.
tags: [loading, core, smoke]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Extract the Stripe calls in `CheckoutController` behind a `PaymentGateway` interface, so we can add a second provider later. Behaviour must not change.
