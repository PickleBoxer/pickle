---
description: A design question the user wants to settle by trying it. prototype should fire, and the reply should treat the prototype as throwaway and name the decision it settles.
expected_outcome: The reply plans or builds a throwaway prototype (a clickable logic demo or a small comparison) that answers the stated question, names the decision, and doesn't treat the prototype as production code.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We're adding order refunds. I can't tell on paper whether a refund should be its own state (paid → refund_requested → refunded) or just a flag on a paid order with partial refunds allowed. I'd like to click through a few cases, like a partial refund followed by a cancellation, before we pick one.
