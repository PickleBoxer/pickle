---
type: llm
---

Judge only the rewritten README intro in the reply, not any commentary around it.

PASS if the rewrite contains no em dash, none of the words "pivotal", "vibrant", "fostering", "showcasing", "intricate", "interplay", "delves", "Additionally" or "landscape", no "not just ..., but ..." construction, no "I hope this helps", and still states that `ledgerctl` is a CLI for Postgres-backed ledgers with cold starts under 3 seconds.

FAIL if any of those patterns remain, or if the rewrite drops `ledgerctl`, Postgres or the 3-second figure.
