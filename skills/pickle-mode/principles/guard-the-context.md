# Guard the context

Context is finite. When it overflows, reasoning degrades, details get lost in compaction, and progress stalls. Spend it on decisions, not on raw material.

**Route bulk elsewhere.**

- Large files, logs, traces, transcripts and search results go to a subagent. It returns a short summary with file and line references. The main thread keeps the summary.
- Read the part of a file you need, not the whole file.
- Do not reread what is already in context.

**Size the work.**

- Cap scope per phase: how many files, how many turns.
- Split work that will not fit into phases with a written handoff between them.

**Write state down.** Files read earlier are not restored after compaction. Anything that must survive goes into the todo list or a file:

- the playbook steps, copied into the todo list
- decisions and their reasons
- the next step and how to verify it

**Before stopping or handing off,** leave a note a new agent can resume from: what is done, what is next, what is uncertain, and how to check the current state.

Related: **principle-minimize-reader-load** is the same idea for human readers.
