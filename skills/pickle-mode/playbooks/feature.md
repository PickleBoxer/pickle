# Feature

Tools: `explore`, `design-options`, implementer subagent, `review`.

You own the design. The implementer writes the code, you review and verify it.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Run `explore` over the code the feature touches: the data it reads and writes, its callers, its tests.
3. Name the data shape before any logic (**principle-model-the-domain**): the states, the transitions, the invalid combinations. Encode it so invalid states cannot be built (**principle-types**).
4. Run `design-options` when there is more than one reasonable shape. Skip it when the shape is obvious from step 3, and say why.
5. Split the work into units that each end in a passing check (**principle-small-verified-steps**). Units that write the same files or state run in sequence, not in parallel.
6. Delegate each unit to an implementer subagent. Give it the file paths, the data shape from step 3, the success check, and the paths of the principle files that apply. When the change replaces an old form, every caller moves and the old form is deleted in the same change (**principle-finish-migrations**).
7. Write or update tests that call the code the way its users do (**principle-test-behavior**).
8. Run `review` on the diff. Comments only where the code cannot say why. Fix what it finds that is real.
9. Verify with `verify.test`, `verify.types` and `verify.lint` from the profile, and `verify.ui` when the change is visible. Show the output (**principle-prove-it-works**).
10. Report what was built, the shape chosen and why, open decisions. End with the Loaded line.
