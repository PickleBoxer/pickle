# Pause safely

Tools: none.

You own a clean stop. A new session with no memory of this one must be able to resume from what you leave.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Stop at a safe point: finish the current small step or back it out. Start nothing new. Stop any running subagents.
3. Take no action that publishes or cannot be undone: no push, no PR, no deploy.
4. Make the work durable. Commit work in progress only if the project's CLAUDE.md allows the agent to commit. Otherwise leave the changes in the tree and list them in the note. Say if the tree is broken.
5. Write `.claude/pickle-handoff.md` for a reader with no context (**principle-guard-the-context**): the goal, the playbook and the current step, what is done and verified, what is not, the next action, key files, decisions and their reasons, traps found. If a decision log exists, point at it instead of copying it.
6. Report where the work stopped, what is on disk and what is not, and the first action on resume. End with the Loaded line.
