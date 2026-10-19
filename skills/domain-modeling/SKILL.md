---
name: domain-modeling
description: Builds and sharpens a project's domain glossary (GLOSSARY.md): challenges terms that clash with it, proposes one canonical word per concept, and writes entries the moment a term is settled. Use when a domain term is fuzzy, overloaded or conflicts with GLOSSARY.md, when naming a new domain concept, or when writing or editing GLOSSARY.md or GLOSSARY-MAP.md.
user-invocable: false
metadata:
  upstream: mattpocock-skills/skills/engineering/domain-modeling
  upstream-version: 1.3.1
---

# Domain Modeling

Actively build and sharpen the project's domain glossary as you design: challenge terms, invent edge-case scenarios, and write each term down the moment it is settled. Merely *reading* `GLOSSARY.md` for vocabulary is not this skill; any skill can do that. This skill is for changing the glossary.

## Where the glossary lives

If `docs/agents/domain.md` exists, it names the layout; follow it. Otherwise most repos have a single context, with one `GLOSSARY.md` at the root:

```
/
├── GLOSSARY.md
└── src/
```

If a `GLOSSARY-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── GLOSSARY-MAP.md
└── src/
    ├── ordering/
    │   └── GLOSSARY.md
    └── billing/
        └── GLOSSARY.md
```

When multiple contexts exist, infer which one the current topic belongs to. If unclear, ask.

Create files lazily: if no `GLOSSARY.md` exists, create one at the root when the first term is resolved.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `GLOSSARY.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the lines between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update GLOSSARY.md inline

When a term is resolved, update `GLOSSARY.md` right there. Don't batch these up: capture them as they happen. Use the format in [references/glossary-format.md](references/glossary-format.md).

`GLOSSARY.md` should be totally devoid of implementation details. Do not treat it as a spec, a scratch pad, or a place for implementation decisions. It is a glossary and nothing else.
