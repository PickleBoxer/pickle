---
name: how
description: Explains how a part of the codebase works (architecture, runtime flow, where things live) at the level of a senior engineer onboarding onto it. Use for "how does X work", walkthroughs before changing unfamiliar code, and placement questions such as "where should this live" or "which module owns this".
argument-hint: "[subsystem, feature or question]"
metadata:
  upstream: pstack/skills/how
  upstream-version: 0.15.43
---

# How

Explore the codebase to answer "how does X work?" questions. For why the code is shaped this way, use the **why** skill (Skill tool, `pickle:why`).

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

## 1. Explain

Spawn one subagent with the Agent tool that explores and explains in one pass: `subagent_type: "Explore"` (read-only; if it is not available, use `"general-purpose"` and add "only read" to the brief), `model: "sonnet"`, `run_in_background: false`. Give it the user's question and this brief:

> You are writing an architectural explanation for a senior engineer. Explore the codebase and write an explanation that a senior engineer unfamiliar with this area could read and walk away with a solid mental model. They should understand the architecture well enough to start working in it confidently. You have read-only access to the codebase. If the project has a `GLOSSARY.md` (or a `GLOSSARY-MAP.md` pointing to one per context), use its terms for domain concepts.

If the Agent tool is not available (for example, inside a subagent at the nesting limit), explore and explain it yourself with the same brief.

## 2. Present

Present the subagent's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.
