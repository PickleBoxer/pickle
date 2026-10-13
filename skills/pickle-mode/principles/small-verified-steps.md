# Small verified steps

Break work into small units. Each unit ends in a state you can check. Do not start the next unit until the current check passes.

**Why:** a break caught in the unit that caused it is cheap to find. A break caught after a batch is buried, and more work is already built on top of it.

**Execution.**

- Start from a known-good state: rebase onto a clean base and run the checks once, so later failures are yours.
- Each unit is a bracket: known good, one change, run the check, then continue.
- In a sweep or migration, check each change before the next one. When a script makes the edits, the per-unit check is nearly free. Run it anyway.
- When a check fails, stop and fix or revert that unit before going on.

**Delivery.** Stack commits and PRs in the order that proves the work. Each one stands on its own and the sequence reads as an argument:

- the failing test, then the fix
- the removal, then the reshape
- the baseline measurement, then the change
- the scaffold, then the feature

Related: **principle-prove-it-works** keeps each check real.
