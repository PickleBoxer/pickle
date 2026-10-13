# Session pickup

Tools: `explore` for long notes or transcripts.

The earlier session's trail is input you trust. Resume from it, do not redo it.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Find the trail: the note the user names, else `.claude/pickle-handoff.md`, else the branch and its recent commits. Read a long note or transcript in a subagent and keep only the summary here (**principle-guard-the-context**).
3. Rebuild the state: the branch, what landed (`git log`, `git diff` against the base), uncommitted changes, open todos, decisions made and why.
4. Compare done against planned and name the resume point. Do not rerun finished work.
5. Check the claims the trail makes about finished work against the code or a command output before building on them (**principle-prove-it-works**). A passing note is not proof.
6. Pick the playbook for the remaining work, read it, and continue there. Its steps replace these from here on.
7. Report where the earlier session stopped, what was inherited, what was redone and why, and the resume point. End with the Loaded line.
