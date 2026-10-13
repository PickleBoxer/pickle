# Finish migrations

When the new design is decided, move every caller to it and delete the old path in the same wave. Do not keep both.

**Steps:**

- Inventory every caller of the old form. Search for the pattern, not one instance.
- Migrate them all, then delete the old API, type, flag or format.
- Update tests to assert the new contract. Delete tests that only protected the old internals.
- A temporary adapter is an exception with an end date, not architecture.

**When it applies:** no external users depend on the old form, and the project can absorb a coordinated change. When external users do depend on it, plan the deprecation as explicit phases with a removal date.

**Aim at the end state.** For a planned migration with several phases, optimize for the correct final state, not for keeping every step perfectly stable. Breakage between phases is acceptable when it is planned, scoped and reversible. State where it is allowed, keep strong checks on the code being touched, and require full verification when the plan completes (**principle-small-verified-steps**).

**Signs you skipped this:** two code paths for the same thing, a `legacy` or `v2` name that has outlived its migration, or a new type converted back to the old one at every call site.
