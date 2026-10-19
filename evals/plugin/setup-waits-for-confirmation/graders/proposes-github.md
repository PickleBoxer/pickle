---
type: llm
---

PASS if the reply summarises what it found, recommends GitHub as the issue tracker because the remote points at github.com, and asks the user to confirm before writing anything.

FAIL if the reply says files were written, recommends another tracker, or asks about triage labels.
