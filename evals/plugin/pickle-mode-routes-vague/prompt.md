---
description: A loading eval dry run. A vague idea with no clear goal, started through pickle-mode. The router's Define phase should send it to interview-me, called by its full pickle:-prefixed name.
expected_outcome: pickle:interview-me is loaded with the Skill tool.
max_turns: 4
allowed_tools: [Skill]
append_system_prompt: "Dry run: call the Skill tool once for each skill you would use for the task, in order, then stop and list them. Don't read, write or run anything else."
---

/pickle:pickle-mode I have a vague idea for something that helps our team with meetings, but I'm not sure what it should be yet.
