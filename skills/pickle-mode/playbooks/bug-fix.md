# Bug fix

Tools: `explore`, implementer subagent, `review`. `design-options` only when the fix crosses a module boundary.

Every changed line traces to evidence. A change that "might help" is a hypothesis. It does not ship.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Reproduce the bug with a failing test that calls the code the way its users do (**principle-test-behavior**). If a test cannot reach it, reproduce it another way and say how.
3. Find the root cause before changing anything (**principle-fix-root-causes**). Run `explore` over the code on the failing path, list the hypotheses, and rule them out with evidence until one survives.
4. Plan the smallest fix the evidence justifies. Run `design-options` only if it crosses a module boundary.
5. Delegate the fix to an implementer subagent with the cause, the failing test and the principle file paths. Revert anything a refuted hypothesis motivated.
6. Run `review` on the diff. Comments only where the code cannot say why.
7. Verify: the failing test from step 2 now passes, then `verify.test`, `verify.types` and `verify.lint` from the profile (**principle-prove-it-works**). Show the output from before and after the fix.
8. Report what was broken, the root cause, the fix and the evidence. End with the Loaded line.
