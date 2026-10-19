---
type: tool_order
arm: with-only
before:
  tool: Skill
  input_match: '"skill"\s*:\s*"(?:[\w-]+:)?(test-driven-development|test)"'
after:
  tool: Skill
  input_match: '"skill"\s*:\s*"(?:[\w-]+:)?codebase-design"'
---
