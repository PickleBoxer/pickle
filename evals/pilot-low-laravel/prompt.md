---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

The `orders.status` column holds the strings `pending`, `paid` and `shipped`. Add a backed `OrderStatus` enum, cast `Order::$status` to it, and replace the string comparisons in the app with the enum.
