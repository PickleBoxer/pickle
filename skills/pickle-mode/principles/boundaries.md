# Boundaries

Applies when wiring framework code, controllers, adapters or third-party APIs, parsing input, or deciding where a check or error handler belongs.

Validate, parse and handle errors at the edges of the system. Trust the inside. Keep business logic in plain functions that do not know about frameworks or vendors.

**At a boundary** (HTTP requests, CLI arguments, config, environment, database rows, queues, third-party APIs):

- Parse raw input into domain types once. Reject what does not parse.
- Handle failures defensively and return clear errors.
- Translate vendor and transport shapes into domain concepts. Do not leak them through the public surface.

**Inside the system:**

- Trust the types. No repeated null checks or re-validation deep in call chains.
- Propagate errors, do not swallow them.
- Business logic is pure: data in, data out, testable without the framework.

**Across a boundary:** expose domain concepts, keep general mechanism inside and special-case policy at the edge. An external service sits behind an interface the domain owns, so a second provider means a second adapter, not new branches.

**The tests:**

- Is this data crossing a boundary right now? If not, validating it again is noise.
- Could this be a pure function the framework code just calls? If yes, extract it.

Related: **principle-types** says what the parsed data looks like. The language pack names the framework's boundary idioms.
