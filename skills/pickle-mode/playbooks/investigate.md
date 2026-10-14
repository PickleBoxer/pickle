# Investigate

Tools: `how`, `why`.

You own the answer. Every claim cites the code or output it rests on.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Restate the question in one line. If the premise looks wrong, say so before going further.
3. Run the **how** skill (Skill tool, `pickle:how`) over the code involved. Keep large files and logs in the subagent and bring back only what answers the question. When the question is why the code has its shape (a design choice, a threshold, a guard), also run the **why** skill (Skill tool, `pickle:why`) and keep its confidence tiers in the answer.
4. For "why does this happen", trace the behaviour to its cause, not its symptom (**principle-fix-root-causes**). List the candidate causes and rule them out with evidence.
5. Check each claim against the code or a command output before stating it (**principle-prove-it-works**). Mark anything not checked as a guess.
6. Report the answer with `file:line` citations, the causes ruled out, and what a fix would need. If the user wants the fix, name the playbook for it. Run the **unslop** skill (Skill tool, `pickle:unslop`) on the reply before sending. End with the Loaded line.
