# Hillclimb

Experimental, ported from pstack.

Tools: `explore`, implementer subagent.

You own the metric and the integrity of the experiment. One change, one measurement, keep or revert.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Run `explore` over the target. Pick a case that reproduces the user's complaint. If none does, fix the reproduction first.
3. Fix one metric, the direction that counts as better, and a stop rule: a target plus a minimum number of attempts, so a lucky early win does not end the run. Use the user's numbers when given.
4. Build one command that prints the metric, run enough times to clear the noise (median of several runs). Check it tells a slow case from a fast one, then freeze it. Record the baseline and a green run of `verify.test` (**principle-prove-it-works**).
5. Keep a decision log outside the tree: one row per attempt with the hypothesis, the change, before, after, and kept or reverted. Read it before each attempt.
6. Loop, one hypothesis per iteration (**principle-small-verified-steps**):
   - Name the mechanism the change targets, not "try caching something".
   - Delegate the change to an implementer subagent with a tight scope.
   - When several independent hypotheses are open, run them in parallel, one subagent each in its own git worktree, each measured on its own. Merge the winners one at a time and measure again after each, since two wins can cancel out.
   - Measure with the frozen command and run `verify.test`.
   - Keep the change only if the metric moves past the noise and the tests stay green. Otherwise revert it in full.
   - Log the row either way.
7. On a plateau, change category, combine near misses, or try something bolder before calling it done. Do not relax the stop rule to meet it.
8. Stop when the rule is met, or when only marginal ideas remain. Say which.
9. Report the metric, baseline to final with the change in percent, attempts kept and reverted, each kept change in one line, the log path, and the best idea not yet tried. End with the Loaded line.
