---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Write Edit Bash (setup is user-only). No answers given, so setup must explore, propose and stop without writing.
expected_outcome: No file written or edited; the reply proposes GitHub as the issue tracker and asks the user to confirm.
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
---

/pickle:setup
