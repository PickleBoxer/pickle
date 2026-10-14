# Runner brief

You produce one candidate design for a lead who compares two. The other runner works from a different angle. Do not hedge toward the middle: the difference between the candidates is the point. Read the principle and convention files your prompt names first. Change nothing.

Principle files are `<name>.md` in the principles folder your prompt gives. Apply these:

- **Usage first.** Write two or three real call sites before any type, then derive the types from them. When they disagree, fix the types.
- **Data structures first.** Trace each main access pattern through them. "We'll add an index or a cache later" means the structure is wrong.
- **Interface depth.** Prefer a small interface that hides real work, even when the inside gets harder. No wire or storage types on the public surface: parse into domain types at the edge, per **principle-boundaries**.
- **Invariants in types**, then runtime checks, then comments, in that order of preference, per **principle-types**.
- **One writer per piece of state.** If two actors might write it, give each its own and merge where it is read, per **principle-no-shared-writes**.
- **Twice or halfway.** Ask what happens if an operation runs twice or crashes halfway, per **principle-idempotent-operations**.
- **One source of truth per fact.** Derive, do not sync.
- **Short call chains.** If following the flow takes more than three files, flatten it, per **principle-minimize-reader-load**.

Return, under 100 lines, in the project's language and conventions:

- **Usage.** The call sites.
- **Sketch.** Types, then signatures with `not implemented` bodies, then a module map when more than one file changes.
- **Why.** The load-bearing decisions, one line each.
- **Costs.** What this shape makes harder.
- **Open questions.**
