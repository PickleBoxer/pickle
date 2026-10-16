---
type: llm
---

Judge only the doc in the reply.

PASS if the doc has a heading that names the task as a verb phrase (for example "Lower the import budget" or "How to lower the import budget"), gives the steps as a numbered list of commands, puts `node scripts/budget.mjs --write` in code font, says to use `--write` only to lower the limit, and contains no em dash.

FAIL if the heading is a bare topic noun ("Import budget"), the steps are prose rather than a numbered list, the `--write` restriction is missing, or an em dash appears.
