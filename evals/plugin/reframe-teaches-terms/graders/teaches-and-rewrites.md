---
type: llm
---

Judge only the final reply.

PASS if it gives 8 to 12 ranked terms for the problem (for example autosave, dirty or pristine form state, optimistic update, unsaved-changes guard, draft, save model), each with a one-sentence meaning, the part of the description it names and a link; names 2 or 3 neighboring fields that solved the same problem (for example document editors, version control, database transactions) with where each analogy breaks; names something the description did not mention; and ends with the description rewritten using the new terms in one fenced code block.

FAIL if it implements or proposes code for the settings page, gives terms with no links, gives fewer than 8 terms, or gives no rewritten description.
