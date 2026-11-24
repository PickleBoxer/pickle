---
description: Single arm, run with --ablation none (in-your-own-words is user-only). A noisy support thread that asks for a refresh button, while the problem underneath is that search shows a product's old name after it is renamed. The skill should restate the goal and the underlying problem in plain words, change nothing, and ask whether it got it right.
expected_outcome: No Edit, Write or Bash; the reply restates the goal and names stale search results after a rename as the problem, not only the refresh button, proposes no fix or plan, and asks whether the restatement is right.
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

/pickle:in-your-own-words Thread from support: "Customer says search is broken again. They renamed 'Blue Mug' to 'Ocean Mug' yesterday and searching 'ocean' finds nothing, but 'blue' still finds it with the new name showing. Can we just add a refresh button to the search page? Also they mentioned the logo looks blurry on retina, not urgent. Priya said last time this happened it fixed itself overnight."
