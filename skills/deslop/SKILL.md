---
name: deslop
description: Removes AI-generated code slop from the branch diff (narrating comments, defensive checks a trusted path never needs, casts that dodge the type system, deep nesting, dead compatibility paths, unrelated edits) without changing behaviour. Use when a pickle playbook step names deslop, before a commit, or when the user asks to deslop or clean up AI-written code.
argument-hint: "[files or base branch]"
metadata:
  upstream: cursor-team-kit/skills/deslop
  upstream-version: 1.2.0
---

# Deslop

Scope: $ARGUMENTS

With no scope, use the diff against the base branch (default `main`), including the working tree. Touch only lines the scope added or changed.

Remove what the branch added that the surrounding code would not have:

- Comments that narrate the code or differ from the file's style. The full comment pass is the **no-comments** skill (Skill tool, `pickle:no-comments`), before review.
- Defensive checks, null guards, try/catch blocks and retries on a trusted path where the rest of the code has none.
- Casts and suppressions that only bypass the type system, such as `as any` or a type-ignore comment. Fix the type instead.
- Deep nesting that early returns flatten.
- Dead compatibility paths: fallbacks for callers that no longer exist, unused parameters, flags that are always on.
- Edits unrelated to the task: reformatting, renames and moves the change did not need.
- Anything else that differs from the file and the code around it: naming, error handling, logging, structure.

Guardrails:

- Behaviour stays the same unless a line is a clear bug. Say so when you fix one.
- Small, focused edits. No rewrites.
- The project's conventions decide what fits. When unsure whether something is slop, leave it and list it.

Report in one to three sentences: what you removed, and anything left for a decision.
