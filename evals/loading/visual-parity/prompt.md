---
description: Loading. Migrating a view with a pixel-identical requirement.
tags: [loading, extended]
runs: 1
max_turns: 12
allowed_tools: [Read, Glob, Grep]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Move the invoice view to the new design system components. It must look pixel identical to today.
