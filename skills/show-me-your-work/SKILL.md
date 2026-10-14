---
name: show-me-your-work
description: Keeps a reviewable decision trail for long-running or unattended work, a TSV log with one row per decision (what, why, evidence, result), audits it against the session transcript and has a second reviewer scan it before handing back. Use when a pickle playbook step names show-me-your-work, for autonomous, hillclimb or multi-phase runs, or when the user asks for a decision log or audit trail of work they review later.
argument-hint: "[log path]"
metadata:
  upstream: pstack/skills/show-me-your-work
  upstream-version: 0.15.24
---

# Show me your work

Log: $ARGUMENTS

Keep one log per piece of work. With no path above, use `decisions.tsv` in the work dir, or `.audit/<task-slug>.tsv` when several efforts run at once. Keep it out of git (add it to `.git/info/exclude`). Commit it only when the work is ambitious enough that a reviewer needs the trail to trust the result.

## The format

One TSV file, one row per decision. Cells stay on one line. Evidence is a pointer, not prose. `${CLAUDE_SKILL_DIR}/references/decision-log-template.tsv` holds the header row. Columns:

- **ts.** ISO 8601 timestamp, UTC.
- **phase.** The phase or workstream.
- **decision.** What was chosen or done, one line.
- **why.** The reason in plain words. If a principle drove it, say it plainly, not as a tag.
- **evidence.** A pointer that proves it: commit SHA, PR number, `file:line`, or an artifact, trace or screenshot path. Never a paragraph.
- **result.** The outcome or predicate state: `tests green`, `reverted`, `pixel-diff 0`, `INCONCLUSIVE`, `open`.

Example:

```
ts	phase	decision	why	evidence	result
2026-05-24T09:02:00Z	frame	counted the work first, about 100 components	wanted the size before starting a long run	commit 3a9f1c2	found 5 things to sort out first
2026-05-24T11:15:00Z	widget	moved the widget styles without changing how it looks	keep the change small and the result identical	commit 7c21e0a, pixel-diff 0	looks identical, tests pass
2026-05-24T12:30:00Z	widget	threw out a subagent's work because its screenshots were blank	checked the files instead of trusting its summary	worktree reset	reverted, tightened the brief
```

## Logging a row

Run `bash ${CLAUDE_SKILL_DIR}/scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>`. It stamps `ts`, writes the header on first use, flattens tabs and newlines, and prefixes a cell starting with `=`, `+`, `-` or `@` with a single quote so a spreadsheet does not run it as a formula. Without Bash, append the row with Write and apply the same rules yourself.

Write each row the way you would tell a teammate what you did: plain words, concrete actions. The **unslop** skill (Skill tool, `pickle:unslop`) applies to log text.

Log decision points and checkpoints, not every action: a fork chosen, a unit done with its verification result, a pivot or revert with its trigger, a blocker, a gate fixed. In a loop, one row per iteration. Skip the trivial.

A run is one session, including its later turns and any compacted summary of it. A resumed session, a new session or a replacement agent starts a new run. When a run adds to a log that already has rows, its first row has phase `start`, and so does its first row after another run's `start` row. So before writing in a later turn, read the last rows to see whether another run wrote since. A `start` row names the `ts` range of the rows before it that this run did not write, and its evidence is this session's id, `${CLAUDE_SESSION_ID}`. Use phase `start` for nothing else.

## Rules

- Append-only. A wrong call gets a new row that supersedes it. Never edit or delete a row.
- Prefer evidence a committed script produces over one-off commands, so a reviewer can rerun it.

## Audit the log against the transcript

At the end of the run, before handing back, check that the log told the truth. This session's transcript is `~/.claude/projects/<project>/${CLAUDE_SESSION_ID}.jsonl` (under `$CLAUDE_CONFIG_DIR/projects/` when that is set). Find it by the session id; never read other sessions' transcripts. The file is written asynchronously, so the latest turn may be missing.

This run's rows begin at one of its `start` rows, or at the first row if this run created the log, and end at the next `start` row of another run. Walk them against the transcript:

- Every row maps to a real decision or action.
- Every evidence pointer resolves and shows what the row claims.
- A fork, pivot or abandoned approach that shaped the work but is not logged is a gap. Add it.

Correct the log, not the story. Never edit or remove a row, even an invented one. Add a row that supersedes it with what happened and a pointer that resolves. Rows outside this run's stretches are not audited; if this run's work shows one is wrong, supersede it like any wrong call.

## Second review of the trail

Before handing back, have an agent that did not do the work scan the trail. Self-review is no substitute. Use the Agent tool with `subagent_type: pickle:pickle-reviewer` (else `general-purpose`, told to change nothing), `run_in_background: false`, and a `model` other than the one running this session. Brief it with the log path, the transcript path and: "Read `${CLAUDE_SKILL_DIR}/references/trail-reviewer.md` first and follow it."

Every reply for a run that produced a trail ends with an **Attention** section, before the Loaded line. Its first line names the reviewer's model (`reviewed by <model>`). Then each flag, pointing to rows or moments. "No flags" is a valid result.

## Reading the trail

Read top to bottom, follow the evidence pointers, spot-check. GitHub renders a committed TSV as a table. `column -s$'\t' -t <logfile>` renders it in a terminal.

Other skills and playbooks route their audit trail here instead of inventing one. Name this skill and let it own the format.
