---
name: design-options
description: Proposes two or three distinct designs for a pickle task in a read-only subagent, with trade-offs and a recommendation. Use when a pickle playbook step says to run design-options.
argument-hint: "<the problem, constraints and explore findings> [principle file paths]"
context: fork
agent: Plan
background: false
metadata:
  upstream: pstack/skills/architect
  upstream-version: 0.15.24
---

Design options for this task:

$ARGUMENTS

1. Read every principle file named above first.
2. Read the code the findings point to. Do not change anything.
3. Propose two or three designs that differ in shape, not in detail: a different data model, a different boundary, a different order of work. Include the smallest design that could work.
4. For each design: the data shape, the files it touches, what it makes easy, what it makes hard, and how it would be verified.
5. Recommend one and say why, in terms of the task and the principles.

Return a short section per design, then a table comparing them, then the recommendation. Keep it under 80 lines.
