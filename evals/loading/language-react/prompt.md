---
description: Language. A feature in a React project loads the project's conventions, then typescript-best-practices and the installed vercel-react-best-practices from the profile.
tags: [loading, language]
runs: 1
max_turns: 14
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: "Loading eval dry run. Follow pickle-mode exactly as you would for real up to and including loading the principles that apply to this task. Then stop: do not explore further, edit, delegate or verify. Reply with the plan in a few lines and end with the Loaded line."
---

/pickle:pickle-mode Add a cancel button to each pending or paid order in src/OrderList.tsx. It posts to the API and the row shows the new status without a reload.
