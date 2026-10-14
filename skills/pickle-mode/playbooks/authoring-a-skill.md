# Authoring a skill

Experimental, ported from pstack.

Tools: the `skill-creator` skill, `interrogate`.

You own what the skill makes another agent do. Every line costs context in every session that loads it.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Use the `skill-creator` skill to draft, test and refine the skill. If it is not installed, tell the user it comes from the official marketplace (`/plugin install skill-creator@claude-plugins-official`) and continue with the steps below.
3. Read the source the skill encodes (a checklist, a runbook, a past session) and the skills already in the project, so the new one does not repeat them.
4. Write the `description` first, in third person: what the skill does, then when to use it, with the words a user would say. It decides when the skill loads.
5. Keep only lines that change what the agent does (**principle-laziness**). The agent is already capable: do not explain basics. Give exact commands or a script for fragile steps, prose for judgment.
6. Write for a reader with no context (**principle-minimize-reader-load**): one term per concept, steps as a checklist the agent copies into its todos, and a check after each step that can fail. Run the **unslop** skill (Skill tool, `pickle:unslop`) on the skill files.
7. Keep `SKILL.md` under 500 lines. Move detail into reference files one level deep, and point to them by path.
8. Validate: frontmatter fields are valid, every referenced file exists, and `claude plugin validate . --strict` passes when the skill lives in a plugin. Then run the **interrogate** skill (Skill tool, `pickle:interrogate`) on the skill files.
9. Test that the skill does what it should: with `skill-creator`'s eval loop for a standalone skill, with `claude plugin eval` for a skill that ships in a plugin. Ask before running either.
10. Report what the skill does, the key decisions, and the test result. End with the Loaded line.
