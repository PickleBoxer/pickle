# Minimize reader load

Applies when reviewing or writing code that is hard to follow, adding a wrapper, adapter or piece of state, or writing anything another person or agent must read, such as a PR description or a skill.

Maintainability is the work a reader must do to understand something. Measure it on two axes:

- **Layers to trace:** the indirections between a question and its answer.
- **State to hold:** the hidden or mutable context the reader must keep in mind.

The axes are independent. A flat file full of globals is as hard as a deep stack of adapters. Line counts and complexity scores are only proxies.

**Cut layers.**

- Inline wrappers with one caller and adapters with one implementation.
- Each layer must change the abstraction. A layer that repeats the same methods and arguments only adds reading.
- Prefer narrow interfaces that hide real decisions over broad ones that hide little.

**Cut state.**

- Prefer return values over mutation, locals over fields, fields over module state, module state over globals.
- Derive values instead of keeping copies in sync.
- State an invariant once, at the boundary, not in every consumer.

Before adding a layer or a piece of state, ask whether it removes at least as much load somewhere else.

**For prose** (PR descriptions, docs, skills): lead with what the reader needs, one idea per sentence, no repetition.

**The test:** can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds?

Related: **principle-guard-the-context** is the same idea for an agent's context.
