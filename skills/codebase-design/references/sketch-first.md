# Sketch First

Before writing logic for a new or reshaped module, sketch its interface, then implement against the sketch. Uses the vocabulary in [SKILL.md](../SKILL.md): **module**, **interface**, **seam**, **depth**. Skip it for a change that adds no module and moves no seam.

1. **Trace every system the change touches:** callers, stored data, wire formats and other modules that read the same state.
2. **Write the usage first.** Before any type, write what a caller writes: what they import, two or three realistic call sites, and what comes back. Then sketch types and signatures with stub bodies. When the usage and the sketch disagree, change the sketch.
3. **Sketch two different shapes:** different module splits or seam placements, not variations inside one shape. To explore interfaces in parallel, use [design-it-twice.md](design-it-twice.md). Pick the shape where each piece of state has one owner, each task has one way to do it, and callers need to know least.
4. **Show the sketch and wait.** Show the user the chosen shape, the one that lost and why, and wait for a go-ahead before filling in the bodies.

If workarounds start to repeat during implementation, redesign instead of patching.
