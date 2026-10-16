---
type: llm
---

PASS if the reply gives a Pest or PHPUnit test that reproduces the bug (InvoiceSplitter::split(10000, 3) summing to 10000, or the missing cent) and presents it as the first step, to be run and seen failing before the class is changed, with the fix coming after it.

FAIL if the reply changes the class without a reproducing test, adds tests only after the fix, never says the test should fail first, or writes the test in a JavaScript framework.
