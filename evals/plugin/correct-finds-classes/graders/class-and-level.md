---
type: llm
---

PASS if the reply names one mistake class for routes importing `src/db.ts` directly instead of going through `src/repositories`, cites both fix commits (the order route and the customer route) as its evidence, picks a level above docs for it (an architecture change such as hiding the db client, or a lint or CI check such as `no-restricted-imports` whose error names the repository to use), and asks the user which classes to fix.

FAIL if the class is fixed only with a line in AGENTS.md or another prose file, if the one-off README typo fix is reported as a class, if the reply says files were changed, or if it applies fixes without asking.
