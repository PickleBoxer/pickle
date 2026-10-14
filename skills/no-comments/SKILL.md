---
name: no-comments
description: Strips comments from a diff before review. A reviewer that did not write the code lists what dies, then this skill deletes it, fixes the code the comments were hiding and offers to encode constraints. Use when a pickle playbook step names no-comments, or when the user asks to strip, clean up or review the comments in a change.
argument-hint: "[files or base branch]"
metadata:
  upstream: pstack/skills/no-comments
  upstream-version: 0.15.24
---

# No comments

Scope: $ARGUMENTS

With no scope, use the current diff against the base branch (default `main`), including the working tree.

The reviewer has a fresh view of the code. Defer to it, and judge only whether it followed its rules.

Keep list: a comment survives only as a legal or license header, behaviour forced by something we cannot reshape (an external dependency, platform, vendor or protocol), a formatter directive or a style-only lint suppression, a doc comment that defines a public API contract, or an issue or RFC link for a constraint the code cannot express.

1. Start the reviewer with the Agent tool: `subagent_type: pickle:comment-sicko`, `run_in_background: false`. Pass the scope. If the agent is not installed, use `general-purpose` and pass the keep list above with: "Review only the comments in this scope. Every comment not on the keep list dies. Change nothing. Report Delete, Keep, MUST KILL, Constraints and Skipped, each with `path:line`."
2. Judge the report.
   - Reject a flag outside the scope, a deletion of a comment on the keep list, a `MUST KILL` whose reason is false, and a flag on code that is intentional and stays.
   - A keep survives only with proof that it is about something we cannot change. A refuted or still unclear keep is deleted.
   - When an `IMPORTANT` or `do not remove` verdict rests on thin evidence, run the **how** skill (Skill tool, `pickle:how`) on its symbol first. A deletion that stays unclear after that stands.
   - Check for lint and type suppressions in the scope that the report missed. One that hides a correctness or safety rule becomes a `MUST KILL`.
   - On a bad report, start the reviewer once more with the failure named. If the second report is also bad, stop and report no-comments as failed.
3. Delete every accepted comment.
4. Fix the `MUST KILL` flags at the root, inside the scope. Trivial ones directly: delete the dead path, drop the parameter, call the real API. When a fix needs a new shape, run the **architect** skill (Skill tool, `pickle:architect`) once for the whole accepted set and implement against its sketch. Remove every workaround a flag names. Never add a symptom guard. If the root cause lies outside the scope, land the smallest fix inside it and report the rest as open.
5. Constraint comments (`do not remove`, `do not change wording`, `talk to X first`): offer the cheapest enforcement inside the scope (a type, a test, a runtime check, a lint rule) and ask with `AskUserQuestion`. Approved: encode it, then delete the comment. Declined, or no one to ask (an unattended run or an eval without approval in the brief): delete the comment and report the constraint as unenforced.
6. Report: deletions, restored comments, reruns, the architect sketch if one ran, fixes, constraints encoded, constraints left unenforced, and open work.
