---
name: swarm
description: Fans out N parallel workers, each in its own git worktree, waits for all of them and returns one report with PASS, ISSUES or BLOCKED per worker. Workers cover separate slices, race the same brief, or both. Use when a pickle playbook step names swarm, or for "swarm this", parallel coverage, races, gauntlets and verifying several commits at once.
argument-hint: "<done predicate> [N] [slices, race or mixed] [principle and convention file paths]"
context: fork
agent: pickle:pickle-lead
background: false
metadata:
  upstream: pstack/skills/swarm
  upstream-version: 0.15.24
---

# Swarm

Run this as a swarm:

$ARGUMENTS

You lead. Workers do the work in their own worktrees, you frame it, check their evidence and write one report. Change nothing yourself.

1. Read every principle and convention file named above.
2. Frame.
   - State the done predicate and what the swarm returns. If the arguments give no predicate you can check, return only `Done predicate unclear:` and one question for the caller. You cannot ask the user from here.
   - Pick the shape: slices (each worker covers its own part), race (every worker gets the same brief), or mixed. For a race or mixed shape, declare the selection rule now: `any pass`, `rank all` or `best-of`.
   - Set N from the arguments, else from the shape. N is total workers.
   - Many slices of one mechanical change across the repo (more than about 5, same edit everywhere) fit Claude Code's `/batch` better. Return only `Use /batch:` and the instruction to give it. Only the user can run it.
3. Brief. Every brief stands alone: the goal, the exact slice or race arm, the files it may touch, the success check, the verify commands, the principle and convention file paths, and: "Read `${CLAUDE_SKILL_DIR}/references/worker.md` first and follow it." A worker that verifies or measures gets the exact commit SHAs, and for a measurement the method: sample count, what one sample is, order.
4. Fan out. Start all N workers in one message with the Agent tool: `subagent_type: pickle:pickle-implementer` (else `general-purpose`), `isolation: "worktree"`, `run_in_background: false`. Set `model` only for a race between models, and name each arm's model in the report.
   - No Agent tool (nested too deep, or nesting turned off): return only `Cannot fan out:` and the briefs, so the caller can run them.
   - A worker that fails to start or dies: go on with N-1 and record it.
5. Check. Wait for every worker. Drop a result that lacks the SHAs, method or evidence its brief asked for, and restart that worker once. A second miss is a gap. A gap never counts as a pass. For slices, every slice needs a result. For a race, apply the rule from step 2.
6. Return the report below, under 60 lines. No raw worker output.

## Report

- **Done predicate.** One line, and whether the swarm met it.
- **Shape.** Slices, race or mixed, N, and the selection rule if any.
- **Results.** A table: worker, slice or arm, `PASS`, `ISSUES` or `BLOCKED`, worktree branch or commit SHAs, one line of evidence.
- **Issues.** One line each with `path:line` and the worker that proved it.
- **Gaps.** Dropped workers, missed slices, results without evidence.
- **Pick.** Race only: the winning arm and why, by the declared rule.
- **Worktrees.** Every worktree left with changes, and what the caller should keep, merge or remove.
