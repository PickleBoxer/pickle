---
name: review
description: Reviews the current diff of a pickle task in a read-only subagent, for correctness bugs and against the named pickle principles. Use when a pickle playbook step says to run review.
argument-hint: "<what the change is for, the base to diff against> [principle file paths]"
context: fork
agent: pickle:pickle-reviewer
background: false
---

Review this change:

$ARGUMENTS

1. Read every principle file named above first.
2. Get the diff: `git diff` against the base named above, else against the default branch, plus uncommitted changes.
3. Review it as your instructions say.

Return:

- **Findings.** One block each: `path:line`, the problem, how to trigger it, how sure you are (certain, likely, possible), the principle it breaks if any.
- **Verdict.** Ready, or not ready and why, in one line.

Keep it under 60 lines.
