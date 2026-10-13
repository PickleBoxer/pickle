# No shared writes

When concurrent actors might write the same state, first ask whether they need to. Usually they do not. Remove the sharing before you try to coordinate it.

1. **Find the shared write targets:** rows, tables, files, cache keys, branches or objects that more than one actor writes.
2. **Default: give each actor its own target.** Ask whether they need one canonical object or are each publishing their own facts. Give each actor its own row, column, key, file or branch, and combine at the point where the data is read. Two workers writing their own fields into one record is still shared mutation. Two records, one per worker, is not.
3. **Only when one shared target is a real invariant, serialize structurally:** a single writer, sequential phases, an atomic compare-and-swap, a unique constraint or a lock. Instructions and conventions are not concurrency control.

Treat "we need a lock" as a design smell to check, not as the default answer.

**During migrations:** when an old system keeps writing while a new one is introduced, decide which side owns each piece of data at every phase. Two systems writing the same data with no owner is the bug to design out.

Related: **principle-idempotent-operations** covers the same actor running twice.
