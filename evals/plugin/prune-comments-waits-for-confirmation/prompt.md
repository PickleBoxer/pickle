---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash Write (prune-comments is user-only). A small TypeScript repo with one comment of each class, plus a license header, a docblock and an eslint directive that are not comments for the skill. In one turn the skill should count with its script, classify, write the run's README to .scratch/ and stop at its one question, with nothing deleted.
expected_outcome: comment-ratchet.sh count runs; a .scratch/prune-comments-*/README.md is written; no Edit and no git command that changes the repo; the reply classifies each comment correctly, leaves the license header, docblock and directive out, and asks whether to go ahead.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write]
---

/pickle:prune-comments src
