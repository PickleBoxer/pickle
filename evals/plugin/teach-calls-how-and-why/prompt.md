---
description: Single arm, run with --ablation none, --scaffold and --allow-tools Bash (teach is user-only). A small HTTP client whose retry backoff is capped at 5 attempts, with the reason in a commit message. Teach should call how and why, then explain with a short ASCII diagram series instead of a reference dump.
expected_outcome: Skill calls to pickle:how and pickle:why; no Edit or Write; the reply opens with a plain definition of exponential backoff tied to src/client.ts, gives the cap's reason from the commit (the upstream rate limit), and has no em dash.
max_turns: 30
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
append_system_prompt: "Non-interactive run: deliver the explanation in one go."
---

/pickle:teach how the retry in src/client.ts works and why it stops after 5 attempts
