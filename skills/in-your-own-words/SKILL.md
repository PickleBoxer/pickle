---
name: in-your-own-words
description: Restates in its own words what the user's goals are and what problem they are trying to solve, before any work starts. Use to check a long or messy ask was understood.
argument-hint: "[ask, thread or report]"
disable-model-invocation: true
metadata:
  upstream: pstack/skills/in-your-own-words
  upstream-version: 0.15.48
---

# In your own words

Restate in your own words what you think the user's goals are and what problem they're trying to solve.

The ask: $ARGUMENTS. Without one, use the conversation so far.

- Plain words, no jargon the user didn't use. Say the underlying problem, not only the request.
- Read what the ask points to (a thread, an issue, a file) before restating it.
- Change nothing and don't start the task. A misreading caught here costs one message.
- End by asking whether that is right. For open questions, the **interview-me** skill (Skill tool, `pickle:interview-me`) asks them one at a time.
