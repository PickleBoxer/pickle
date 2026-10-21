# Sketch First

Before writing logic for a new or reshaped module, sketch its interface: the caller's code first, then types and signatures with stub bodies. Then implement against the sketch. Uses the vocabulary in [SKILL.md](../SKILL.md): **module**, **interface**, **seam**, **depth**.

Skip it for a change that adds no module and moves no seam.

## 1. Write the usage first

Before any type, write what a caller writes: what they import, two or three realistic call sites in their own code, and what comes back. The usage is the spec. The type sketch is derived from it, and when the two disagree, change the sketch, not the usage.

## 2. Sketch the shape

- Core types and data structures first. Trace each main access pattern through them. "We'll add a map or a cache later" means the structure is wrong.
- Signatures with stub bodies that throw `not implemented`, pseudocode as `TODO` comments for the tricky logic, and a doc comment for each invariant. A reader should trace data from input to output through types and signatures alone.
- Invariants in types where the language allows it, runtime checks where it doesn't, prose last.
- Parse outside data into domain types at the seam. No transport or wire types on the interface.

For a small change, the sketch is one file of types and signatures. For a larger one, add a module map: which module owns which state, and which seams sit between them.

## 3. Sketch at least two shapes

Sketch at least two structurally different shapes, even when the first looks good enough: different module splits or seam placements, not small variations inside one shape. To explore interfaces in parallel, use [design-it-twice.md](design-it-twice.md). Compare the shapes on **depth**: prefer the one that hides more behind a smaller interface.

## 4. Screen for red flags

Shallow modules and pass-throughs are covered by [SKILL.md](../SKILL.md) and the deletion test. Also reject or revise a shape that shows any of these. Assume the next contributor sees only the files it opened, copies the nearest example and takes the shortest path that compiles.

| Red flag | What it looks like | Fix |
|---|---|---|
| Information leakage | One internal decision (a format, a policy, a protocol detail) appears in several modules, so changing it needs coordinated edits | Give the decision one owner behind its interface |
| Temporal decomposition | Modules named for when they run (load, validate, transform, save), each repeating the same representation | Group by the knowledge a module owns, not by execution order |
| Split ownership | Two modules write the same state or keep their own copy | One owner. Others read it or ask the owner to change it |
| Two ways to do one task | Callers can do the same thing two ways, and each keeps gaining callers | Keep one way. Move callers off the other and delete it |
| Importable internals | Callers can import a module's internals, so the internals become interface | Make internals unreachable from outside, so such an import fails the build |
| Hand-synced lists | Adding an item means editing several lists | Keep one list and derive the rest, or fail the build when they disagree |

## 5. Show the sketch before implementing

Show the user the chosen sketch with a short rationale and wait for a go-ahead before filling in the bodies. The rationale has these parts, one page at most:

- **Problem.** What the module must do, and the constraints that make its shape non-obvious.
- **Usage.** The caller's code from step 1.
- **Shape.** The types and the main decisions: which invariants live in types, where parsing happens, what the module deliberately doesn't do.
- **Tradeoffs.** One line each: "we accept X in exchange for Y".
- **Alternatives.** At least one other shape from step 3, with one line on why it lost.
- **Open questions.** Phrased as questions for the user.

If the user pushes back on the shape, go back to step 1 with their objection as a new constraint. Don't patch the sketch.

## 6. Implement against the sketch

Replace the stub bodies with code. The sketch is the contract. When a function needs something the sketch didn't plan for, such as a new parameter, stop and decide which is wrong: the sketch, the requirement or the implementation. Say which, rather than absorbing the change silently.

## 7. Scrap a sketch that keeps fighting back

Throw the sketch out when implementation keeps producing friction it can't absorb. The signal is a pattern, not one awkward case:

- The same kind of workaround appears in unrelated places.
- Several unrelated edge cases each need their own special-case branch.
- Types need escape hatches (`any`, casts, optional fields that are always set) to compile.
- A lock is needed for state the sketch said wasn't shared.
- Callers need to know the module's internal rules to use it.
- Two or more deviations from step 6 have the same shape.

When you scrap it, redesign as if the new constraints had been there from the start. Remove what the old sketch added before sketching again. The new sketch should be smaller than the old one before it grows. Then go back to step 1.
