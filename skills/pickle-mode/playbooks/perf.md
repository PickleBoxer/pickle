# Perf

Tools: `benchmark-checklist`, `how`, implementer subagent, `interrogate`. `architect` only when the fix crosses a module boundary.

Every fix is tied to a measurement. Do not reason about speed from reading the code alone.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Measure a baseline on the real path: time, query count, memory, whatever the task names. Record the command and the number (**principle-prove-it-works**). Vet the baseline, and every later number, with the **benchmark-checklist** skill (Skill tool, `pickle:benchmark-checklist`).
3. Run the **how** skill (Skill tool, `pickle:how`) over the slow path to form hypotheses, then confirm them with measurement.
4. Try the cheapest fix first, in this order: do not do it, do not do it again, do less, do it later, do it concurrently, do it cheaper. Stop at the first that meets the target (**principle-laziness**).
5. Delegate each attempt to an implementer subagent, one change at a time, measured before the next (**principle-small-verified-steps**). Revert an attempt the numbers do not support.
6. Run the **interrogate** skill (Skill tool, `pickle:interrogate`) on the diff. Comments only where the code cannot say why.
7. Measure again with the same command as step 2 and vet the result with the **benchmark-checklist** skill (Skill tool, `pickle:benchmark-checklist`). Then `verify.test`, `verify.types` and `verify.lint` from the profile.
8. Report the baseline, the new number, the delta and the command that produced them. End with the Loaded line.
