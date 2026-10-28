---
type: llm
---

PASS if the review reports that `placeOrder` writes the customer's email to the log with `console.log`, and ties it to the repo's rule against logging customer emails, as a finding to fix before merge (Critical or an unprefixed required change).

FAIL if the review does not mention the logged email, or files it as a Nit, Optional, Consider or FYI.
