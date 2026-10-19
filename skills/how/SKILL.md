---
name: how
description: Explains how a part of the codebase works (architecture, runtime flow, where things live) at the level of a senior engineer onboarding onto it. Use for "how does X work", walkthroughs before changing unfamiliar code, and placement questions such as "where should this live" or "which module owns this".
argument-hint: "[subsystem, feature or question]"
metadata:
  upstream: pstack/skills/how
  upstream-version: 0.15.25
---

# How

Answer "how does X work?" with an architectural explanation: enough for a senior engineer new to the area to build a working mental model, not so much that it reads like annotated source code. For why the code is shaped this way, use the **why** skill (Skill tool, `pickle:why`).

## 1. Assess complexity

If the scope is ambiguous, state your reading in one line and go on. The user can redirect.

- **Simple**: one module, a small utility, a narrow question such as "how does function X work". Explore and explain it yourself, then go to step 3.
- **Complex**: a subsystem across several files or services, a cross-cutting feature, a full architectural overview. Go to step 2.

When in doubt, take the simple path.

## 2. Explore (complex only)

Split the question into 2 to 4 angles, each a distinct slice of the subsystem. Spawn one explorer per angle with the Agent tool, all in one message so they run at the same time:

- `subagent_type: "Explore"` (read-only). If it is not available, use `"general-purpose"` and keep the prompt's "only read" line.
- `run_in_background: false`. Leave `model` unset.
- The prompt is `references/explorer-prompt.md` with the question and the angle filled in.

If the Agent tool is not available (for example, inside a subagent at the nesting limit), explore each angle yourself in turn.

## 3. Explain

Write the explanation yourself from the explorers' findings, or from your own reading on the simple path. Follow `references/explainer-prompt.md`: reconcile overlaps, check contradictions in the code, and use its sections, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.

Name gaps the explorers flagged instead of hiding them.

If the project has a `GLOSSARY.md` (or a `GLOSSARY-MAP.md` pointing to one per context), use its terms for domain concepts.
