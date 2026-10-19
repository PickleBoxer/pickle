---
description: An HTTP contract request that belongs to api-and-interface-design. codebase-design covers internal module shape, so it must not fire.
expected_outcome: api-and-interface-design is invoked; codebase-design is never invoked.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Design the REST endpoint for paging through orders: query parameters, response shape, error format, and how we version it.
