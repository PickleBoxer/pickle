---
type: tool_order
arm: with-only
before:
  tool: Skill
  input_match: '"skill"\s*:\s*"(?:[\w-]+:)?documentation-and-adrs"'
after:
  tool: Skill
  input_match: '"skill"\s*:\s*"(?:[\w-]+:)?domain-modeling"'
---
