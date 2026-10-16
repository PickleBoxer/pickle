---
description: A loading eval dry run. A review request started through pickle-mode. The router's Review phase should load code-review-and-quality, called by its full pickle:-prefixed name.
expected_outcome: pickle:code-review-and-quality is loaded with the Skill tool.
max_turns: 4
allowed_tools: [Skill]
---

/pickle:pickle-mode Review the last commit.

Dry run: load the skills you would use for this task, in order, then stop and list them. Don't read, write or run anything.
