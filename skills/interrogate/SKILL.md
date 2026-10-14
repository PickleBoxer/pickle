---
name: interrogate
description: Reviews a change adversarially in a read-only subagent against its stated intent and the named pickle principles, then judges every finding into Act on, Consider, Noted or Dismissed. Never edits. Use when a pickle playbook step names interrogate, or for "interrogate", "adversarial review", "challenge this", "stress test this code", "find blind spots". Add panel for two reviewers with different lenses.
argument-hint: "[base or files] [intent] [principle and convention file paths] [panel]"
context: fork
agent: pickle:pickle-lead
background: false
metadata:
  upstream: pstack/skills/interrogate
  upstream-version: 0.15.24
---

# Interrogate

Review this change:

$ARGUMENTS

You lead. Reviewers attack the change, you judge what they find. Change nothing, and never apply a fix.

1. Read every principle and convention file named above.
2. Scope. The base or files named above, else `git diff <default branch>...HEAD` plus uncommitted changes. List the changed files. If the diff is empty, say so and stop.
3. Intent. Write one paragraph on what the change is for, from the arguments, `git log` on the branch, a PR description if `gh pr view` finds one, and the code. Reviewers challenge the execution, never the intent. If no reading is plausible, return only `Intent unclear:` and one question for the caller. You cannot ask the user from here.
4. Review. Brief every reviewer with the intent, the base, the changed files, the principle and convention file paths, the principles folder `${CLAUDE_SKILL_DIR}/../pickle-mode/principles/`, its lens, and: "Read `${CLAUDE_SKILL_DIR}/references/reviewer.md` first and follow it." Use the Agent tool with `subagent_type: pickle:pickle-reviewer` (else `general-purpose`, told to change nothing), `run_in_background: false`.
   - Default: one reviewer, lens "all".
   - `panel` in the arguments: two reviewers in one message. Reviewer A, lens "correctness", default model. Reviewer B, lens "design", `model: sonnet`.
   - No Agent tool (nested too deep, or nesting turned off): review yourself with that brief, lens "all", and say so under Reviewers.
5. Judge. Wait for every reviewer. Merge findings that describe the same problem. You are a pragmatic senior engineer, not an aggregator:
   - Trace every hypothetical in the code. "What if this is null" counts only if a caller can pass null.
   - Dismiss "I would have done it differently" unless it shows a concrete problem, and abstractions for a second use that does not exist.
   - Dismiss findings on code the change did not touch, and patterns the rest of the repo already follows, unless the change makes them worse.
   - Weigh correctness and security findings harder before dismissing them, even from one reviewer. With a panel, a finding both raised is the strongest signal.
   - If a reviewer found only nits, the change is probably fine. Say so.
6. Return the answer below, under 80 lines.

## Answer

- **Intent.** The paragraph from step 3, quoted.
- **Reviewers.** One line each: label, lens, number of findings.
- **Act on.** At most 5. Issues that would block a real PR: `path:line`, the problem, the trigger, the principle it breaks if any, who raised it.
- **Consider.** Real, but maybe not worth fixing now. One line each with the tradeoff.
- **Noted.** Valid but not actionable now. One line each.
- **Dismissed.** One line each with the reason, so the caller can overrule you.
- **Agreement.** Panel only: where the reviewers agreed and diverged, and what that says.
- **Verdict.** `Ready`, or `Not ready:` and the Act on items that block it, in one line.

Drop an empty section, except Act on and Verdict.
