---
description: Single arm, run with --ablation none (sharpen is user-only). A thin task prompt. Sharpen should name the four parts and hand back one rewritten prompt in a code block without doing the task.
expected_outcome: No Edit, Write or Bash; the reply names what a top professional would add, the raw material, the methods and tools, and an outside check, then gives the rewritten prompt in one fenced code block and leaves the user's choices open.
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

/pickle:sharpen write a migration guide for moving our config from YAML to TOML
