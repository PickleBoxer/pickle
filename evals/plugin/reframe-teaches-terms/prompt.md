---
description: Single arm, run with --ablation none (reframe is user-only). A vague description of a settings page that saves some fields at once and others on submit. Reframe should name the expert terms with links, borrow from neighboring fields, rewrite the description in a code block, and change nothing.
expected_outcome: No Edit, Write or Bash; the reply ranks 8 to 12 terms (such as autosave, dirty state, optimistic update, unsaved-changes guard), each tied to part of the description with a link, names 2 or 3 neighboring fields with where the analogy breaks, names something unmentioned, and gives the rewritten description in one fenced code block.
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, WebFetch, WebSearch]
---

/pickle:reframe the settings page saves some fields right away and others only on submit, and people lose edits.
