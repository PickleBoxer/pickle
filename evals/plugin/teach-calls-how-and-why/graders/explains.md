---
type: llm
---

Judge only the final reply.

PASS if it opens with a plain definition of retry with exponential backoff and ties it to `src/client.ts`, gives the reason for the cap from the commit message (the payments API rate limit of 100 requests per minute, or the outage where unbounded retries kept the client over it), includes at least one ASCII diagram in a code block, and contains no em dash.

FAIL if it is mainly a list of constants and functions, gives a reason for the cap that the commit does not support without saying it is inferred, uses a Mermaid block, prints framing labels such as "key insight" or "TL;DR", or contains an em dash.
