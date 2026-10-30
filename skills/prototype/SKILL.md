---
name: prototype
description: Builds a throwaway prototype to settle a design question by trying it: a clickable logic demo, switchable UI variants or a small script. Use when the user wants to feel out a state model or a UI, or settle a "which approach" question by running something.
argument-hint: "[the design question]"
metadata:
  upstream: mattpocock-skills/skills/engineering/prototype
  upstream-version: 1.3.1
---

# Prototype

A prototype is **throwaway code that answers one question**. The question decides its shape, and the deliverable is the decision, not the code.

## 1. Name the decision

Write down the one decision the prototype exists to make: which state model, which layout, which approach. No decision means no prototype: build it for real with the **incremental-implementation** skill (Skill tool, `pickle:incremental-implementation`).

Before asking the user a "which approach" or "what should this do" question, check whether running something would answer it (behavior, timing, layout, output). If it would, prototype first and bring the user the result, not the abstract question. A product or preference call that no experiment can settle still goes to the user.

## 2. Pick a branch

- **"Does this logic or state model feel right?"** → [references/logic.md](references/logic.md). One shareable HTML file with free-play buttons and guided walkthroughs that push the model through cases that are hard to reason about on paper.
- **"What should this look like?"** → [references/ui.md](references/ui.md). Several structurally different UI variants on one route, switched with a `?variant=` URL parameter and a floating bar.
- **"Which approach behaves better?"** (timing, ordering, output, resource use) → the smallest script that exercises each approach on realistic input and prints what you are deciding on: the timing, the output, the order of events. No framework, no tests. The observation is the test.

The branches produce very different artifacts, so getting this wrong wastes the prototype. If the question is ambiguous and the user can't be asked, pick the branch that matches the surrounding code (a backend module: logic; a page or component: UI) and state the assumption at the top of the prototype.

## 3. Rules for every branch

1. **Throwaway from the start, and named as such.** Put it next to the code it prototypes, with `prototype` in the file or route name. Follow the project's existing conventions; don't invent a new top-level structure.
2. **Trivial to run.** One command from the project's task runner, or one HTML file to double-click.
3. **No persistence by default.** State lives in memory. If the question is about persistence, use a scratch database or file clearly named for deletion.
4. **Skip the polish.** No tests, no error handling beyond what makes it run, no abstractions.
5. **Surface the state.** After every action or variant switch, show the full relevant state, so the user sees what changed.
6. **Propose variants the user didn't ask for** when the design space is open. Two or three real alternatives beat one.

## 4. Present the result

Show the variants and the evidence (screenshots, the observed output or timing), the tradeoffs, and your recommendation. Then wait for the user's pick.

## 5. Capture it and move on

- Keep the prototype itself as a primary source on a throwaway branch such as `prototype/<name>`, not on the main branch. Record the question, the variants and the verdict in that branch's commit message.
- Leave a pointer to the branch where the real work is tracked: the issue, `SPEC.md` or `tasks/plan.md`.
- The main branch gets only the validated decision. Build it for real with the **incremental-implementation** skill (Skill tool, `pickle:incremental-implementation`): prototype code was written without tests or error handling, so rewrite it rather than promoting it. A pure logic module from [references/logic.md](references/logic.md) is the one part that can lift across, with tests added.
