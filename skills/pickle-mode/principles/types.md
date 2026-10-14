# Types

Let the type checker reject impossible states, mixed-up values and unhandled cases. Prefer designing a case out of existence over handling it everywhere. The project's conventions name the syntax for each idea.

- **Make illegal states unrepresentable.** Model variants as a closed set (enum, sum type, sealed class), not as a bag of optional fields where contradictory combinations are allowed. If you need a comment explaining which field combinations are valid, split the type.
- **Build types from the values you want.** A non-empty list is a first item plus the rest. A valid range is a start plus a length. Pick the shape that cannot hold the illegal value.
- **Give distinct meanings distinct types.** An order ID and a customer ID may both be integers, but they should not be interchangeable. Validate once on creation, trust the type afterwards.
- **External data is untyped until parsed.** Requests, JSON, config, environment variables and database rows go through a parse step at the boundary (**principle-boundaries**).
- **Do not lie to the type checker.** Casts, forced unwraps and suppressions are runtime failures waiting to happen. Prove the fact (validate, narrow) or treat the cast as a known hazard and trace it to a boundary.
- **Exhaustive handling is the checker's job.** A match over a closed set must fail to check when a new variant appears unhandled, so the checker shows the next person where to add the case.
- **Derive from the source of truth.** When a schema, migration or spec owns a shape, derive the type from it instead of writing a parallel one.
- **Strengthen a type only where it is partial.** A runtime assertion or "should never happen" error marks a type that is too weak. Move that check into the type, then stop. The goal is to make each use site handle the right cases, not to describe the data as precisely as possible.
