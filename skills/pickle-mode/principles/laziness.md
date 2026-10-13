# Laziness

Applies when sizing a change, sequencing an addition or refactor, or when tempted to add an abstraction, layer, option or guard the task did not ask for.

The best change is the smallest one that solves the problem. The best addition starts with a removal.

**Subtract first.**

- Remove dead code, unused options and stale references before building anything new. Build on the simpler base.
- Get to the minimum that works before polishing it.
- Leave the code slightly simpler than you found it, behind the same or a smaller surface.

**Then add as little as possible.**

- Make the smallest diff that solves the problem. Fewer lines beat elegant boilerplate.
- Design for the usage you can observe, not for edge cases you imagine.
- No validators, parsers, guards, flags or extension points beyond what the task demands.
- Decide each thing once. If the same choice appears in several places, put it behind one source of truth and pass the result.
- A file or section with nothing new in it gets deleted, not left as a stub.

**The test:** for every line in the diff, can you name the requirement that needs it? If not, cut it.

Exception: a prototype is throwaway, so polish and minimal diffs do not matter there. Laziness still applies to scope.
