# Idempotent operations

Every operation that changes state should converge to the correct end state, whether it runs once, twice, or after a crash halfway through.

**Ask of every state-changing operation:**

1. What happens if it runs twice in a row?
2. What happens if the previous run crashed at each possible point?
3. Does running it again always reach the same end state?

If any answer is "it depends on what the last run left behind", the operation needs a reconciliation step.

**Patterns:**

- **Check, then converge.** Read the current state and move it toward the target, instead of applying a blind change ("set status to shipped if not shipped" rather than "ship").
- **Claim before acting.** When several workers can pick the same item, claim it atomically (a conditional update, a unique key, a lock) before doing the work.
- **Idempotency keys** for external calls that must not repeat, such as payments and emails.
- **Convergent startup.** On start, scan for existing state, clean up stale artifacts and adopt work that is still live.
- **Self-healing locks.** A lock records its owner, so a stale lock from a dead process can be detected and cleared.
- **Clean retries.** Failed work can be retried from scratch without manual cleanup.

Related: **principle-no-shared-writes** covers several actors writing the same state at the same time.
