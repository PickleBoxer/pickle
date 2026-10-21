---
type: llm
---

PASS if the reply proposes or builds a throwaway prototype that lets the user try both refund models (separate state vs flag with partial refunds) on concrete cases such as a partial refund followed by a cancellation, states the decision it is meant to settle, and says the prototype is not production code.

FAIL if the reply just recommends one model from reasoning alone, starts building the real refund feature, or presents the prototype as code to ship.
