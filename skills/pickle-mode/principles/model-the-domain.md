# Model the domain

Applies when writing stateful logic, adding a branch to an existing if/else chain, or when the same shape check repeats across files.

Get the data shape right first. Then encode the domain in a structure, not in conditionals spread across files.

**Data first.** Before writing logic, name the core types and data structures, trace how each is read and written, and pick structures that fit the main access paths. A structure chosen at write time is cheap. Recovering it later looks like a refactor and gets postponed.

**Reach for a structure that fits:**

- A state machine or a closed set of states instead of booleans, phases or lifecycle checks that must stay in sync.
- A typed model or value object instead of loose parameters and repeated shape assumptions.
- A map, registry or lookup table instead of a branch per case spread across files.
- A reducer or command and event model instead of ad hoc mutations.
- A module that owns one body of domain knowledge, instead of modules named after steps (load, validate, transform, save). Execution order is not ownership.
- A queue, cache, index, tree or normalized collection when the access pattern calls for it.

When nothing fits, write down what the code must never allow and how the data is read, then pick the structure that encodes exactly that.

**Do not force it.** Plain code is fine when the shape is already clear, local and unlikely to grow. Distrust a structure that adds indirection without removing branches, duplicated rules or invalid states.

**Scaffold first.** Shared types, test setup and tooling that every later step benefits from go first.

**Signs you skipped this:** a feature that adds one more branch to an existing chain, a second boolean that must stay in sync with a first, or the same domain rule repeated in several step-named modules.

Related: **principle-types** makes the structure enforceable. **principle-no-shared-writes** covers state that concurrent actors share.
