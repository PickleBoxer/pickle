# Investigate

Tools: `explore`.

You own the answer. Every claim cites the code or output it rests on.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Restate the question in one line. If the premise looks wrong, say so before going further.
3. Run `explore` over the code involved. Keep large files and logs in the subagent and bring back only what answers the question.
4. For "why does this happen", trace the behaviour to its cause, not its symptom (**principle-fix-root-causes**). List the candidate causes and rule them out with evidence.
5. Check each claim against the code or a command output before stating it (**principle-prove-it-works**). Mark anything not checked as a guess.
6. Report the answer with `file:line` citations, the causes ruled out, and what a fix would need. If the user wants the fix, name the playbook for it. End with the Loaded line.
