---
name: explore
description: Maps the code a pickle task touches in a read-only subagent and returns file:line pointers and short findings. Use when a pickle playbook step says to run explore.
argument-hint: "<what to explore and why> [principle file paths]"
context: fork
agent: pickle:pickle-explorer
background: false
metadata:
  upstream: pstack/skills/how
  upstream-version: 0.15.24
---

Explore the code for this task:

$ARGUMENTS

Return, in this order:

1. **Answer.** What the code does that matters for the task, in a few lines.
2. **Map.** The files and symbols involved, one line each with `path:line`: where the data is defined, read, written and tested.
3. **Verify.** The commands that test, type-check and lint this area, if you found them.
4. **Risks.** Anything that could break or surprise: other writers of the same data, missing tests, code that runs twice.
5. **Not checked.** What you did not read.

Keep it under 60 lines.
