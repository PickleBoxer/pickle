# Redesign from first principles

Do not bolt a new requirement onto the current design. Design as if it had been a requirement from the start, then move the code there.

1. Read every affected file and understand the current design and why it has its shape.
2. Ask: if we were writing this today, with the new requirement known, what would we build?
3. Compare that design with the current one. The difference is the change, not the shortest path to make the new case work.
4. Carry the change through every reference: types, names, tests, docs and examples. A redesign that leaves old names or old explanations behind is half done.
5. Think through the whole redesign, then deliver it in small verified steps (**principle-small-verified-steps**).

**Signs you skipped this:** the new case lives in an `if` at the edge of the old design, a flag that only the new caller sets, or a comment explaining why the new path is different.

Distinct from **principle-fix-root-causes**, which questions an assumption behind a failure. This one rebuilds a design around a new requirement.
