---
type: llm
---

PASS if the reply has an Accepted table that routes the console.log finding to a deterministic mechanism (an eslint `no-console` rule, a hook, a pre-commit or CI check), also flags the test command (`npm test` not running the tests) or the missing guardrail (lint and tests in no CI job or pre-commit hook), and asks the user which rows to apply.

FAIL if the console.log finding is routed only to a line in CLAUDE.md or another prose file, if the reply says files were changed, or if it applies fixes without asking.
