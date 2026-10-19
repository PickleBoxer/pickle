---
description: A firing chain. An ADR whose decision names domain concepts, in a repo with a glossary. documentation-and-adrs should fire, then call its domain-modeling extension, and the ADR should land in docs/adr/. Needs --scaffold and --allow-tools Write Edit.
expected_outcome: documentation-and-adrs is invoked, then domain-modeling; docs/adr/0001-*.md is created; GLOSSARY.md gains or sharpens a term (for example "sale" listed under _Avoid_ for Order, or an OrderPlaced event term).
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Record an ADR for this decision: Billing no longer reads the orders table. Ordering owns Orders, and Billing learns about them only from OrderPlaced events keyed by OrderId. We also agreed that what Billing used to call a "sale" is an Order.
