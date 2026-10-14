# Visual parity

Experimental, ported from pstack.

Tools: `how`, implementer subagent, `interrogate`.

You own pixel-identical output. The baseline is the spec, and an image diff is the judge, not your eye.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Run the **how** skill (Skill tool, `pickle:how`) over the view: its states, its data, the components it uses.
3. Before changing anything, capture the baseline: screenshots of every state of the view through `verify.ui`, with fixed data, viewport and fonts. Turn them into a test that fails on any pixel difference (**principle-test-behavior**). No baseline, no parity claim.
4. Never edit the baseline, the harness or the view's data to make a diff pass. If the baseline looks wrong, stop and ask.
5. Migrate shared pieces first, as a blocking step. Then fan out: one implementer subagent per view or component, each in its own git worktree, all diffing against the same baseline. Merge them one at a time and diff again after each merge.
6. After each step, diff against the baseline (**principle-prove-it-works**). Any nonzero diff fails. Find the pixels that moved and fix the cause.
7. Run the **interrogate** skill (Skill tool, `pickle:interrogate`) on the diff. Then `verify.test`, `verify.types` and `verify.lint` from the profile.
8. Report each component migrated with its diff result, the baseline location, and what is left. End with the Loaded line.
