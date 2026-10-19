---
type: llm
---

PASS if the reply changes processOrder to receive the payment gateway (a parameter, constructor argument or port) instead of constructing StripeGateway inside it, gives the tests a fake or in-memory gateway, and asserts on what processOrder returns or what the fake recorded.

FAIL if the tests mock the './stripe' module (jest.mock, vi.mock or similar) while processOrder still constructs StripeGateway itself, or if no test is written.
