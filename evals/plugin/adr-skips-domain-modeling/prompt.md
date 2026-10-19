---
description: An ADR for a pure technology choice, with no domain concepts. documentation-and-adrs should fire and write to docs/adr/, and must not call domain-modeling. Needs --allow-tools Write.
expected_outcome: documentation-and-adrs is invoked; domain-modeling is never invoked; the ADR is created under docs/adr/.
max_turns: 16
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

Record an ADR: we're moving the background job queue from Redis to Postgres (SELECT ... FOR UPDATE SKIP LOCKED) so we run one less service.
