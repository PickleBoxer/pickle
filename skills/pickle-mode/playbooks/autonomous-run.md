# Autonomous run

Experimental, ported from pstack.

Tools: `show-me-your-work`, plus whatever the remaining work needs through its own playbook.

You own the exit condition. Define done, then drive to it without stopping to ask.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. State the exit condition as a check you can run before the first iteration: all tests green, the reproduction passes, the PR is merge-ready.
3. Pick the playbook that fits the work (for failing tests, usually bug-fix), read it, and use its steps inside each iteration.
4. Each iteration makes the smallest change the evidence supports, runs the exit check, and keeps the change only if it moved the check forward (**principle-small-verified-steps**). Revert anything that did not help.
5. Drive the iterations with `/loop`. Without an interval it paces itself. With one (`/loop 10m ...`) it suits waiting on something outside, such as CI or a deploy: size the interval to when the result is worth reading.
6. Fix what you find on the way: a flaky test, a broken tool, a related bug. Then return to the exit condition. Stop and ask only for a gate, an action that publishes or cannot be undone, a product decision no experiment can settle, or a real dead end.
7. Log each iteration as one row with the **show-me-your-work** skill (Skill tool, `pickle:show-me-your-work`): what changed and whether the check moved. Before the report, run its audit and second review.
8. A plateau is not a stop. Change approach. Never weaken the exit condition to declare success.
9. Report the exit condition, iterations run, what was kept, what was reverted, and the final state of the check. End with the Loaded line.
