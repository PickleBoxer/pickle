---
name: unslop
description: Removes AI writing patterns from prose (filler, AI vocabulary, hedging, dashes, mannered phrasing) while keeping the meaning and tone. Use when a pickle playbook step names unslop, or when the user asks to unslop, de-AI, tighten or clean up a reply, PR description, commit message, doc, plan or skill.
argument-hint: "[file path, or the text to clean]"
metadata:
  upstream: pstack/skills/unslop
  upstream-version: 0.15.24
---

# Unslop

Clean this text: $ARGUMENTS

With no argument, clean the reply or document being written now.

1. Scan the text for every pattern below.
2. Rewrite each hit. Keep the meaning, the facts and the intended tone. Code, commands, quotes and identifiers stay as they are.
3. A file: edit it in place. A reply or a message: rewrite it before sending.
4. When asked for a review rather than an edit, list each hit as the rule number, the line and the rewrite.

## Patterns

Rule numbers are stable ids that other skills cite. A removed rule leaves a gap.

### Content

3. **Superficial -ing phrases.** "highlighting...", "ensuring...", "reflecting...", "showcasing...", "fostering...". Delete, or say what it does.
5. **Vague attributions.** "Experts believe", "Industry reports suggest", "Some critics argue". Name the source or delete.

### Language

7. **AI vocabulary.** Additionally, crucial, delve, enduring, enhance, fostering, garner, interplay, intricate, landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore, vibrant. Replace with plain words.
8. **Fancy ways to say "is".** "serves as", "stands as", "boasts", "features". Say "is" or "has".
9. **"Not just X, but Y."** State the point directly.
10. **Rule of three.** Don't force ideas into groups of three. Use the natural number.
11. **Synonym cycling.** Protagonist, main character, central figure and hero in one paragraph. Pick one word and repeat it.
12. **False ranges.** "from X to Y" where X and Y are not on a scale. List the topics.

### Style

13. **Dashes.** No em dashes, no en dashes, no hyphen used as a dash. End the sentence, use a comma, or put an aside in parentheses. Hyphens in compound words are fine.
14. **Colon overuse.** Colons are fine before a list or an example, not as mid-sentence connectors. "If you're coming from traditional automation: instead of registering event handlers, you describe conditions" becomes "Describe when the scheduler should fire in plain English."
15. **Boldface overuse.** Don't bold every proper noun or acronym.
16. **Inline-header lists.** The tell is a bold label and colon that restate the line: "**Performance:** Performance improved...". Turn those into prose. A bold lead-in that ends in a period, names the item and is followed by new detail ("**Schema in TypeScript.** Tables live in one file.") is fine.
17. **Title case headings.** Use sentence case.
18. **Decorative emojis.** Remove them from headings and bullets.
19. **Curly quotes.** Use straight quotes.

### Communication artifacts

20. **Chatbot phrases.** "I hope this helps!", "Let me know if...", "Of course!", "Certainly!", "Found the smoking gun!" Remove.
22. **Sycophantic tone.** "Great question! You're absolutely right!" Answer directly.

### Filler

23. **Filler phrases.** "In order to" becomes "To". "Due to the fact that" becomes "Because". Delete "It is important to note that".
24. **Excessive hedging.** "could potentially possibly be argued that it might" becomes "may".
25. **Generic conclusions.** "The future looks bright." State the specific plan or fact.

### Jargon

26. **Abstract metaphor nouns.** Substrate (base), wedge, wedge in (add), vector (way, method), locus, vantage, nexus, primitive as a noun, harness as a metaphor, surface as in "API surface", bedrock, scaffolding as a metaphor, modality, paradigm, gold-plating (more than the job needs), ratchet as a metaphor (the mechanism's real name, or a limit that only tightens), evacuate for moving code (move out), endgame (the last phase), north star, flywheel. Pick the concrete word.

### Plain speech

27. **Say what it does, not how it feels.** "the database stays close at hand" and "types that follow your schema" name a feeling. Name the mechanism or a number instead: "`.toSQL()` returns the exact string sent to the database", "a column rename fails the build". If a sentence cannot become a concrete instruction, fact or number, cut it. If it could appear unchanged in another project's docs, it says nothing about this one. Cut it.
28. **Dense sentences.** If the reader has to backtrack, split the sentence or drop clauses. One idea per sentence.
29. **Active voice.** Catch "is/are/was/were + past participle" and name the actor: "queries are validated" becomes "the compiler validates queries". Passive only when the actor is unknown or does not matter.
30. **Adverbs.** "runs quickly" becomes "is fast" or the number. "significantly improves" becomes the measured delta. An adverb propping up a weak verb means the verb is wrong.
31. **Plain words.** "utilize" and "leverage" become "use", "facilitate" becomes "help", "numerous" becomes "many", "in the event that" becomes "if".
32. **Mannered prose.** Metaphor or flourish where a literal phrase exists: aphorisms ("wire it or delete it"), rhetorical fragments, personified code ("the plan holds it"), figurative verbs ("rides along", "stands on"), stock framing. "A dial worth turning" becomes "a parameter worth varying". Rule 26 covers the metaphor nouns.
33. **Over-compression.** Dropped articles, verbless fragments, symbol-speak and abbreviations the reader must decode. "Parser rejects bad date → exit 2, no write" becomes "The parser rejects a bad date, exits with code 2 and writes nothing."
