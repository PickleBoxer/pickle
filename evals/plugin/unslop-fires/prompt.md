---
description: A request to clean up a README intro full of AI writing patterns. The unslop skill should fire and the rewrite should drop the patterns.
expected_outcome: A rewrite with no em dashes, none of the flagged AI vocabulary, and no "not just X, but Y" construction, keeping the facts (Postgres, the CLI name, the 3-second cold start).
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Clean this README intro up before I publish it, it reads like AI wrote it:

> In today's fast-paced landscape, `ledgerctl` serves as a pivotal tool — not just a CLI, but a gateway to seamless ledger management. It boasts a vibrant ecosystem, fostering collaboration and showcasing the intricate interplay between your data and Postgres. Additionally, it delves into cold starts, ensuring they stay under 3 seconds. I hope this helps you get started!
