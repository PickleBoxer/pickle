# Test behavior

A test calls the code the way its users do and asserts what they would observe, against a literal expected value.

**The check:** would the test still pass if every function it imports returned nothing? If yes, it observes no behaviour and cannot catch a defect. Rewrite the assertion or delete the test.

**Shapes that fail the check:**

- **Weak or no assertion:** only "is defined", "is truthy", "does not throw", "is an instance of", "is greater than zero".
- **Mock or absence only:** only "was called", "was not called", "is empty", "is not this wrong value".
- **Self-referential:** the expected value comes from the code under test, such as comparing `f(a)` with `f(a)`.
- **Constant pin:** the assertion restates a constant, config default or message string from the code.
- **Fixture asserts fixture:** the assertion reads data the test built itself, and the subject never runs.

**The fix:**

- Call the subject in the test body with one concrete input and assert the literal output or the observable effect (the response, the stored row, the sent message).
- For an absence, assert the presence for the other input in the same test.
- For a constant, test the mechanism that reads it with one input.
- For a mock, assert the payload it received or the state after the call, not that it was called.
- When no such assertion exists, delete the test.

**Keep** tests of relations across data (a key present in two tables, a parent that exists) and compile-time type tests.

The project's conventions name the test framework's idioms.
