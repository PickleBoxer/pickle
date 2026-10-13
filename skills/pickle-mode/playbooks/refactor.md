# Refactor

Tools: `explore`, `design-options`, implementer subagent, `review`.

You own the contract. The structure changes, the behaviour does not.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Run `explore` over the code to move: its callers, its tests, what it depends on.
3. Pin the current behaviour before moving anything: existing tests, or new tests that call the code the way its users do (**principle-test-behavior**). Type checks and lint are not a pin.
4. Name the target shape as if it had been built that way from the start (**principle-redesign-from-first-principles**). Keep framework code, adapters and third-party services at the edges, the core free of them (**principle-boundaries**). Run `design-options` when more than one target shape is reasonable.
5. Delete before adding: dead code, one-caller wrappers, redundant checks (**principle-laziness**).
6. Delegate the move to an implementer subagent in small steps, each keeping the pin green. Every caller moves to the new shape and the old one is deleted in the same change (**principle-finish-migrations**). No shims, no old and new side by side.
7. Run `review` on the diff. The change must make the code easier to read somewhere, or it is reverted. Comments only where the code cannot say why.
8. Verify: the pin passes unchanged, then `verify.test`, `verify.types` and `verify.lint` from the profile (**principle-prove-it-works**).
9. Report the structure that changed, the pin it held against, and the evidence. End with the Loaded line.
