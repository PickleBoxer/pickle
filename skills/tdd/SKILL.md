---
name: tdd
description: Reproduces a bug as a focused failing test before the fix, then shows the same test passing after it. Use when a pickle playbook step names tdd, or when the user asks for TDD, a failing test first or a regression test. Skips the new test when no cheap, focused test path exists.
argument-hint: "<bug: intended vs actual behaviour> [principle and convention file paths]"
metadata:
  upstream: pstack/skills/tdd
  upstream-version: 0.15.24
---

# TDD

Make the broken behaviour executable before any production code changes: one focused test that fails before the fix and passes after it.

$ARGUMENTS

Read every principle and convention file named above first. The conventions name the test framework and its idioms.

## Red

1. State the intended behaviour, the actual behaviour and the smallest input that shows the difference.
2. Pick the narrowest test the project already uses for that code path: unit, component or integration. If no cheap path exists, go to "No cheap test".
3. Write the smallest test that would have caught the bug. Call the code the way its users do and assert the literal value or effect they would observe. Check: would it still pass if the code under test returned nothing? Then it observes nothing; rewrite it.
4. Run only that test. It must fail, and for the reason the bug gives. A pass, or a failure for another reason (setup, typo, missing fixture), means the test is wrong: fix the test, not the code.

## Green

5. Fix with the smallest production change that gives the intended behaviour and keeps nearby contracts. When the caller hands the fix to someone else (a pickle playbook delegates it to an implementer), stop after red and pass on the test, its command and the failure output.
6. Run the test again: it passes. Then run the tests around it.

## No cheap test

Skip the new test when it would need broad harness setup, brittle mocks, slow end-to-end infrastructure, production-only state or a vague reproduction. Use the closest executable check instead: a script, a reproduction command, browser automation, a log assertion. No test is better than a bad one: a test of mocks, of implementation details, of timing, or one deleted right after it proves the fix.

## Guardrails

- Never change a test to match wrong code. Never weaken an existing assertion unless the intended behaviour changed, and say why.
- Keep the test on this bug. No fixture churn, no unrelated coverage. Sibling cases come after the focused fix lands.
- A flaky bug: make the test deterministic and name the signal it locks down.

## Report

- The failing-before test or check, its command and the failure it gave.
- The passing-after run, and the nearby tests run.
- Without failing-before evidence: why, and the check used instead.
