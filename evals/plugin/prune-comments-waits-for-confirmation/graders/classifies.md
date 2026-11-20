---
type: llm
---

PASS if the reply classifies "add the item to the cart" as Tautology; the TODO about hardcoded prices as Excuse, with an issue title; the fetchLegacy() note and the commented-out legacyClient line as Stale; the per-line tax rounding comment as a Decision Record to keep; and the integer-cents comment as a Decision Record for an ADR. It leaves the Copyright header, the addItem docblock and the eslint-disable line out of the deletions, and it ends by asking whether to go ahead.

FAIL if the reply says a comment was deleted or an issue was filed, marks the license header, the docblock or the eslint-disable line for deletion, marks the rounding comment for deletion, or ends without asking.
