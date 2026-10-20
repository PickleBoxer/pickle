---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash Write (the skill is user-only). The same repo with "report only": the skill writes the report and stops, with no grilling and no question about which candidate to explore.
expected_outcome: An architecture-review-*.html is written to .scratch/reports/; no Edit; the reply points at the report and ends without a question round.
max_turns: 40
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write]
---

/pickle:improve-codebase-architecture report only
