---
description: A firing eval. A naming question that clashes with the pasted glossary. domain-modeling should fire on its own description and the reply should flag the clash and propose glossary entries.
expected_outcome: domain-modeling is invoked; the reply flags that the new words are listed under _Avoid_ or clash with Customer, separates the organization from the people ordering for it, and proposes entries in the glossary format.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Our GLOSSARY.md has this entry:

```md
**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

We're adding client accounts: a company account with several users who place orders on its behalf. What should we call these things? Show me the glossary entries; don't write files.
