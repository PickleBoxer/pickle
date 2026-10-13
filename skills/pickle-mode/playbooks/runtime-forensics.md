# Runtime forensics

Experimental, ported from pstack.

Tools: `explore` to map the finding back to source.

You own the diagnosis. Measure the live process, do not theorize from source. No fix unless asked.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Check the profile gates before touching a production process. Prefer read-only capture.
3. Capture a real signal from the running process: a CPU profile or stack samples for a spinning process, a heap snapshot for a leak, thread dumps for a hang, its logs for the window in question.
4. Reduce the capture to the cause: the hot function, the loop that runs without input, the chain that keeps an object alive. Read large captures in a subagent and keep only the finding here (**principle-guard-the-context**).
5. Confirm the mechanism before believing it: a second capture, a log line, or a safe probe that shows the cause in action (**principle-prove-it-works**). Otherwise call it the strongest hypothesis, not the cause.
6. Map the finding to source with `explore`: file, symbol, the line that loops, allocates or waits.
7. Report the signal captured, the finding, how it was confirmed, the source location and the capture paths. Name the playbook for the fix (bug-fix or perf). End with the Loaded line.
