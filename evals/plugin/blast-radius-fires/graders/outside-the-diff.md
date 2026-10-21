---
type: llm
---

PASS if the reply says that anything reading `created_at` from the serialized order (API clients, a frontend, another service, stored JSON, tests or fixtures) breaks because the key is renamed to `createdAt`, AND it names the fact the change's safety depends on (for example "no consumer reads `created_at`") and says whether that fact is proven or unproven.

FAIL if the reply treats the rename as safe without checking for consumers, or never says whether the safety fact was proven.
