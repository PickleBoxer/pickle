# Pack template

Copy this file to start a pack for a new language. A pack holds only the language half of the principles: the principle files already say what and why, the pack says how in this language. Keep it under 120 lines, one line per idea, concrete names and commands.

Save it as `packs/<language>.md` in pickle, or anywhere in the project and list its path under `packs:` in `.claude/pickle.md`.

Rules:

- Write a section only for a principle that has a real language form. Skip the rest. Process principles (laziness, minimize-reader-load, redesign-from-first-principles, small-verified-steps, guard-the-context) rarely need one.
- Name the language's own idioms, tools and commands. Never restate the principle.
- No version numbers that will go stale, unless a feature only exists from that version on.
- Delete these instructions and every line in angle brackets.

---

# <Language> pack

The <language> half of the principles, plus default verify commands and the language server. Each section gives only the <language> form of one principle: read the principle file first, then apply it with the lines below.

## Verify commands

The profile's verify commands win. Without a profile, use the first that exists in the project:

| Purpose | Command |
|---|---|
| test | <project script, then the test runners in order of preference> |
| types | <type checker or compiler> |
| lint | <linter, formatter check> |

<How to run one test while iterating.>

## Language server

With a language server, the LSP tool finds definitions and references and reports errors after edits, more reliably than grep. If the LSP tool is not available for `<.ext>` files, suggest it once in the reply. Do not install it.

- `<lsp plugin>@<marketplace>`. Server: `<install command>`.

## principle-types

- <Closed sets, exhaustive matching, distinct ID types, the escape hatches that lie to the checker.>

## principle-boundaries

- <Where input is parsed and with what, how errors propagate, where framework code ends.>

## principle-model-the-domain

- <The idiomatic shape for a state machine and for one owner of a transition.>

## principle-idempotent-operations

- <Conditional writes, unique keys, job and webhook deduplication in this stack.>

## principle-no-shared-writes

- <The concurrency model and its structural tools: actors, channels, transactions, locks last.>

## principle-test-behavior

- <Test framework idioms for calling the subject and asserting literal output, and how to fake the edges.>

## principle-fix-root-causes

- <Where the real error is, the stale state to suspect, debug output to remove.>

## principle-finish-migrations

- <Deprecation markers that make the toolchain list callers, codemod tools.>

## principle-prove-it-works

- <Benchmark and profiling tools, and which build to measure.>
