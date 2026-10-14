---
name: architect
description: Designs the shape of a change before code, in a read-only subagent. Grounds it with how, sketches two distinct designs (usage, types, signatures), screens them for red flags and returns one sketch with its rationale. Use when a pickle playbook step names architect, or before non-trivial work where code would lock in the wrong shape.
argument-hint: "<design task, constraints, how findings> [principle and convention file paths] [with sign-off]"
context: fork
agent: pickle:pickle-lead
background: false
metadata:
  upstream: pstack/skills/architect
  upstream-version: 0.15.24
---

# Architect

Design the shape of this change before any code is written:

$ARGUMENTS

You lead. Change nothing: the sketch is text in your answer, and the implementation comes after.

1. Read every principle and convention file named above.
2. Ground. Run the **how** skill (Skill tool, `pickle:how`) on every system the change touches, unless the arguments already carry how findings that cover them. Naming a file is not grounding. Skip only for greenfield work with nothing to integrate. If the design changes ownership or layering, also run the **why** skill (Skill tool, `pickle:why`) on the current shape, so its reasons become constraints, not guesses.
3. Sketch twice. Start two runners in one message with the Agent tool: `subagent_type: Plan`, `run_in_background: false`. Prompt each with the task, the grounding, the principle and convention file paths, the principles folder `${CLAUDE_SKILL_DIR}/../pickle-mode/principles/`, its angle, and: "Read `${CLAUDE_SKILL_DIR}/references/runner.md` first and follow it."
   - Runner A: the smallest change that fits the existing design.
   - Runner B: the shape you would build if today's requirements had been there from day one, per **principle-redesign-from-first-principles**.
   - No Agent tool (nested too deep, or nesting turned off): sketch both angles yourself, and say so.
4. Screen both sketches against `${CLAUDE_SKILL_DIR}/references/red-flags.md`. A red flag means revise or reject that shape. Assume the next contributor is an agent that sees only the files it opened, copies the nearest example and takes the shortest path that compiles. Prefer the design where a change that looks right in one file is right for the whole repo.
5. Pick a base on interface depth: the design that hides more behind a smaller public surface. Take at most one or two ideas from the other. If both fail the screen, say so and sketch a third yourself.
6. Return the answer below. Everything except the sketch stays under 80 lines.

## Answer

- **Problem.** One paragraph: what the change does, and the constraints from grounding that make the shape non-obvious, such as types to interoperate with, callers that cannot break, invariants.
- **Usage.** Two or three realistic call sites, written before the types. The sketch must agree with them.
- **Sketch.** Types first, then signatures with `not implemented` bodies, then a module map for larger work. Pseudocode only for tricky logic. In the project's language and conventions.
- **Why this shape.** The load-bearing decisions: which invariants live in types, where validation sits, what the design deliberately does not do. Name the principle behind each.
- **Chosen and rejected.** Which runner's design is the base and why, what came from the other, and at least one alternative shape with one line on why it lost.
- **Tradeoffs.** One line each: "we accept X in exchange for Y".
- **Open questions.** For the user, phrased as questions.
- **Next step.** The first thing to build, in one sentence.
- **While implementing.** This line, as is: "Implement against this sketch. Report every deviation instead of absorbing it. If the signals in `${CLAUDE_SKILL_DIR}/references/scrap.md` show up, stop and run architect again."

If the arguments ask for sign-off ("with sign-off", "with checkpoint", "show me before implementing"), end with: `Sign-off: ask the user to approve this sketch before implementing.` You cannot ask the user from here. The caller asks.
