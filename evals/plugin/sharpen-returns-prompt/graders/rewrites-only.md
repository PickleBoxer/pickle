---
type: llm
---

Judge only the final reply.

PASS if it says what a top professional would do that the prompt does not ask for, names the raw material they would start from, names specific methods or tools, names a check other than the user or the assistant that would show the guide is right (for example running the converted config through the loader or a test), and then gives one rewritten prompt in a fenced code block. Choices that belong to the user, such as which config keys to cover or the guide's audience, are left open or asked about, not decided.

FAIL if the reply writes the migration guide itself, gives no rewritten prompt, gives the prompt outside a code block, or the rewrite only adds length (more sections, more formats) without the raw material, methods or outside check.
