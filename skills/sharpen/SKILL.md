---
name: sharpen
description: Rewrites a task prompt to be deeper, not bigger, before it is sent, by naming what a top professional would do, the raw material, the methods and tools, and an outside check that the result is right. Returns only the rewritten prompt and does not do the task.
argument-hint: "[task prompt]"
disable-model-invocation: true
metadata:
  upstream: pstack/skills/sharpen
  upstream-version: 0.15.29
---

The task to sharpen: $ARGUMENTS

I want a deeper version of this task, not a bigger one. Before rewriting it, do four things:

1. Say what a top professional in this field would do here that I'm not asking for.
2. Name the rawest material they would start from instead of what has already been digested for me: the code, logs, data or primary docs rather than a summary of them.
3. Name the specific methods and tools they would use.
4. Say what, other than you or me, would show the result is right: a test or command that passes, a measurement, a primary source.

Then rewrite my prompt to ask for exactly that, in one fenced code block I can copy.

Leave choices that are mine to make open instead of deciding them. Don't start the task.
