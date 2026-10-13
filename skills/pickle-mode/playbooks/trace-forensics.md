# Trace forensics

Experimental, ported from pstack.

Tools: `explore` to map the finding back to source.

You own the diagnosis from the capture. It already exists: read it, do not rerun it. No fix unless asked.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Identify the format (CPU profile, trace, heap snapshot, log) and the tool that reads it. Read a large capture in a subagent, never whole into this context, and keep only the finding here (**principle-guard-the-context**).
3. Turn it into something you can query: a script that totals time per function, or rows in a database. Get to the totals before reading details.
4. Narrow to the cause: the frames with the most time and the call path to them, the retainer chain for a leak, the blocked thread and what it waits on.
5. Map the hot frame to file, symbol and line. A frame with no source mapping is not a diagnosis yet. Resolve it, or say the capture does not carry symbols.
6. With a second capture from before or after, compare the two to confirm. Without one, call the finding the strongest hypothesis the capture supports (**principle-prove-it-works**).
7. Report the capture and its format, the finding with numbers, the source location, and whether it was confirmed. Name the playbook for the fix (bug-fix or perf). End with the Loaded line.
