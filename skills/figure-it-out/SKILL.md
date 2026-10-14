---
name: figure-it-out
description: Designs an auditable playbook when no pickle playbook fits, then runs it. For a large migration across many call sites, an ambitious multi-part change, or work the user steps away from and reviews later. Scales rigor to the stakes, runs each unit as a hypothesis, and keeps a decision trail. Use when a pickle playbook step or pickle-mode names figure-it-out, or when the user says "figure it out".
argument-hint: "<task> [principle and convention file paths]"
metadata:
  upstream: pstack/skills/figure-it-out
  upstream-version: 0.15.24
---

# Figure it out

Task: $ARGUMENTS

When no playbook fits, design one. The first deliverable is the workflow itself: phases that scale rigor to the task, run each unit as an experiment, and leave a trail a human can audit after stepping away.

A `**principle-<name>**` mention below is the file `${CLAUDE_SKILL_DIR}/../pickle-mode/principles/<name>.md`. Read it when its step starts.

## Start

Copy phases A to E into the todo list. Read every principle and convention file named above. If pickle-mode is not already loaded, read the Principles index in `${CLAUDE_SKILL_DIR}/../pickle-mode/SKILL.md`.

## A. Frame

Ground first with the **how** skill (Skill tool, `pickle:how`), then commit. Do not start the run until you can state:

- Done, as a check that can fail (**principle-prove-it-works**).
- Scope in numbers: rough units and effort, and the blockers grounding found.
- The rigor level, biased high. One-way doors and a wide blast radius get more, reversible low-stakes steps less. Rigor is gates and artifacts, not trying harder.

Show the framing and tradeoffs before a long run. Reversible work goes on without waiting, but a multi-hour run earns one checkpoint with `AskUserQuestion`. A gate in the profile always stops.

## B. Design the workflow

Cut the work into units that each land on their own, riskiest unknown first. Scaffold and verification before features (**principle-model-the-domain**, **principle-small-verified-steps**).

- Build the verification harness before the work, with a baseline from the state before the change, so each check reads "old value against new value".
- For a one-way-door design decision, run the **architect** skill (Skill tool, `pickle:architect`) with sign-off. Skip it for mechanical work whose shape is already clear. A second design pass over a settled shape is waste (**principle-laziness**).
- Decide what fans out. Parallel work only across seams, each worker in its own worktree, one writer per piece of shared state (**principle-no-shared-writes**). For several slices with one done check, the **swarm** skill (Skill tool, `pickle:swarm`). Do not over-fan.
- Write the phase list down. That list is what the human reviews.

Then add the designed steps to the todo list between C and D, and run each under C, logging under D as each lands.

## C. Run the loop

Each unit is an experiment: state the hypothesis, make the smallest change, measure against the done check on the real artifact, keep it if it moved forward, revert it if not. Verify each unit before starting the next.

- Verify by inspecting the artifact, never a report. When something passes too easily, suspect the check before the system.
- Pair delegated work with a judge: the **interrogate** skill (Skill tool, `pickle:interrogate`) on the unit's diff. If a worker games the gate, reset and tighten the brief. If the gate is wrong, fix it in its own change instead of routing around it.
- A verdict is VERIFIED, NOT VERIFIED or INCONCLUSIVE. Inconclusive is not a pass. Do not hide a negative.

## D. Keep the trail

Log the run with the **show-me-your-work** skill (Skill tool, `pickle:show-me-your-work`), one row as each step lands. This work is usually ambitious enough to commit the trail, so the reviewer reads it with the diff.

## E. Verify and hand back

Check the whole against the done check from A on the real product, not only the harness. Turn any correction you made more than once into a gate, a lint rule, a check or a script.

Report the playbook you designed, the rigor level and why, the trail path, what is verified against the done check, and what is still open.
