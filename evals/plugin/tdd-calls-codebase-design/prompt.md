---
description: A firing chain. A test request for a function that builds its own Stripe client. test-driven-development should fire, then call its codebase-design extension for the seam, and the reply should inject the gateway instead of module-mocking it.
expected_outcome: test-driven-development is invoked, then codebase-design; the reply makes the gateway a parameter or port with a fake adapter for tests and tests through processOrder, rather than mocking the './stripe' module.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Write tests for processOrder. It charges the card through Stripe, and the tests must not hit Stripe.

```ts
import { StripeGateway } from "./stripe";

export async function processOrder(order: Order) {
  const gateway = new StripeGateway(process.env.STRIPE_KEY!);
  const charge = await gateway.charge(order.customerId, order.totalCents);
  return { orderId: order.id, chargeId: charge.id, status: "paid" as const };
}
```
