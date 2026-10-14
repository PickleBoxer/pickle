---
name: how
description: Explains how code works in a read-only subagent, with the flow, where things live and what could surprise, as path:line pointers. Use when a pickle playbook step names how, or to answer how something works or where code belongs before changing it.
argument-hint: "<question and why> [principle and convention file paths]"
context: fork
agent: pickle:pickle-lead
background: false
metadata:
  upstream: pstack/skills/how
  upstream-version: 0.15.24
---

# How

Answer this question about the code:

$ARGUMENTS

You lead. Explorers read the code, you pick their angles and write the answer. Change nothing.

1. Read every principle and convention file named above.
2. Size the question. If the scope is ambiguous, state your reading and go on.
   - Simple (one module, one function, one narrow question): one explorer, angle "the whole question".
   - Complex (a subsystem across files or services, a cross-cutting flow, a full overview): 2 or 3 explorers, each on a distinct angle, for example entry points and data flow, storage and side effects, tests and boundaries.
   - In doubt, simple.
3. Start every explorer in one message with the Agent tool: `subagent_type: pickle:pickle-explorer` (else `Explore`), `run_in_background: false`. Prompt each with the question, its angle, the principle and convention file paths above, and: "Read `${CLAUDE_SKILL_DIR}/references/explorer.md` first and follow it."
   - No Agent tool (nested too deep, or nesting turned off): explore yourself with that brief, and say so under Not checked.
4. Wait for every explorer. Merge overlaps. Settle contradictions by reading the code yourself. Read more only to fill a gap.
5. Return the answer below, under 80 lines.

## Answer

Drop a section with nothing to say.

- **Overview.** One or two paragraphs: what it is, what it does, why it exists.
- **Key concepts.** The types, services or abstractions the rest needs, one line each.
- **How it works.** The flow step by step: what triggers it, what runs, where the data goes, the decision points. `path:line` on every step. Prose, not pseudocode. A mermaid diagram only when the flow crosses several components and prose is harder to follow.
- **Where things live.** The files needed to start working here, one line each.
- **Verify.** The commands that test, type-check and lint this area, if found.
- **Gotchas and risks.** Surprises and what could break: other writers of the same data, missing tests, code that runs twice.
- **Not checked.** What no one read, and the explorers' open questions.

Write concretely: "`UserService` calls `AuthClient.refresh()`", not "the service delegates to the client". Mark inferred claims as inferred.
