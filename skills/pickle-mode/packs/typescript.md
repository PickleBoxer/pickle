<!-- TODO: written from memory, not checked against docs. Verify every command, API and version claim against the official docs, then delete this comment. Least certain: `noUncheckedIndexedAccess`, `satisfies` on lookup tables, BullMQ `jobId`, `no-floating-promises`, `knip` and `ts-prune`, `vitest bench`, the typescript-lsp install command. -->

# TypeScript pack

The TypeScript and JavaScript half of the principles, plus default verify commands and the language server. Each section gives only the TypeScript form of one principle: read the principle file first, then apply it with the lines below. Lines marked React or Node apply when `package.json` depends on them.

## Verify commands

The profile's verify commands win. Without a profile, prefer the `package.json` scripts (`test`, `typecheck`, `lint`), run with the package manager the lockfile names: `pnpm-lock.yaml` is pnpm, `yarn.lock` is yarn, `bun.lock` is bun, `package-lock.json` is npm. Otherwise use the first that exists:

| Purpose | Command |
|---|---|
| test | `vitest run`, `jest`, `node --test` |
| types | `tsc --noEmit` (`tsc -b` for project references, `vue-tsc --noEmit` for Vue) |
| lint | `eslint .`, `biome check` |
| format | `prettier --check .`, `biome format` |

Run a single test file or pattern while iterating, the full suite before saying done.

## Language server

With a TypeScript language server, the LSP tool finds definitions and references and reports type errors after edits, more reliably than grep. If the LSP tool is not available for `.ts` files, suggest it once in the reply. Do not install it.

- `typescript-lsp@claude-plugins-official`. Server: `npm install -g typescript-language-server typescript`.

## principle-types

- `strict: true` in `tsconfig.json`. `noUncheckedIndexedAccess` when the project can take it.
- A closed set is a string literal union or a discriminated union with one tag field (`kind`, `status`), not a bag of optional fields.
- Exhaustive `switch` over a union ends with `const unhandled: never = value`, so a new variant fails to compile. A lookup table uses `satisfies Record<Status, X>`.
- Distinct meanings get a branded type, `type OrderId = string & { readonly __brand: 'OrderId' }`, created by one parse function.
- `any`, `as`, non-null `!` and `@ts-ignore` are lies to the checker. Use `unknown` and narrow. `@ts-expect-error` with a reason, only where a test checks a type error.
- Derive types from the source of truth: `z.infer<typeof Schema>`, generated database or OpenAPI types, `(typeof values)[number]` from an `as const` array.

## principle-boundaries

- `JSON.parse`, `fetch` responses, request bodies, `process.env` and `localStorage` are `unknown` until a schema (zod, valibot, or the project's choice) parses them.
- Parse environment variables once, in one config module. Code imports the parsed config, never `process.env`.
- Node: handlers parse, call one function with domain types, and map the result to a response. Errors reach one error handler or middleware.
- React: components get parsed domain data. Fetching and parsing live in a loader, hook or server function, not inline in the markup.
- A third-party SDK sits behind a module the app owns, which maps its types and errors to domain ones.

## principle-model-the-domain

- State as a discriminated union, `{ status: 'pending' } | { status: 'paid'; paidAt: Date }`, not `isPaid` plus an optional `paidAt` that must stay in sync.
- React: related state that changes together goes in one `useReducer` with typed actions, not several `useState` calls.
- Transitions live in one function per change (`cancel(order)`), returning the new state.

## principle-idempotent-operations

- Database writes converge with `upsert` or `ON CONFLICT` behind a unique constraint, or a conditional `UPDATE ... WHERE status = 'paid'` whose row count decides what happens next.
- Queues: a stable job ID so a duplicate enqueue is dropped (BullMQ `jobId`, or the queue's equivalent).
- Webhooks: store the provider's event ID under a unique constraint and skip duplicates. Outgoing payments: pass the provider's idempotency key.
- React: effects run twice in development under `StrictMode`. An effect must be safe to run twice and must clean up what it starts.

## principle-no-shared-writes

- Single-threaded is not race-free. Read, `await`, then write lets another request or handler interleave. Push the condition into the write (a conditional update, a unique constraint).
- React: derive state from props or other state instead of copying it, and use the functional form `setCount((c) => c + 1)` when the next value depends on the last.

## principle-test-behavior

- Call the function, or the route through the app (`supertest`, the framework's request helper), and assert the returned value or response body with `toEqual` on a literal.
- React: Testing Library queries by role and visible text, drives the UI with `userEvent`, and asserts what the user sees. Never component state or internals.
- Mock the network at the edge with MSW, not by mocking `fetch` or the module under test.
- `toHaveBeenCalledWith(payload)`, never only `toHaveBeenCalled()`.
- Large snapshots are constant pins. Use them only for small, reviewed output.
- Type tests (`expectTypeOf`, `tsd`) are compile-time tests and stay.

## principle-fix-root-causes

- Reproduce with a failing test before the fix.
- Read the real stack trace with source maps (`node --enable-source-maps`).
- An error swallowed or reported out of order: suspect a missing `await` first. The `@typescript-eslint/no-floating-promises` rule finds them.
- "Works locally", "fails in CI" or "fails after upgrade": suspect stale build output and caches (`dist`, `.next`, `*.tsbuildinfo`, the bundler cache) and a lockfile out of sync with `package.json`.
- Remove `console.log` and `debugger` before saying done.

## principle-finish-migrations

- Find every caller with LSP references and grep for the string forms too: route paths, event names, keys in JSON.
- Mechanical sweeps: a codemod (`ts-morph`, `jscodeshift`) beats hand edits.
- Mark the old export `/** @deprecated use X */` while callers move, then delete it. `knip` or `ts-prune` finds exports nobody imports.

## principle-prove-it-works

- Measure a production build, not the dev server. React development mode renders twice and skips optimizations.
- Timing: `vitest bench` or a script with many iterations and the spread, never a single run.
- Bundle size: build, then read the bundler's report or a source map explorer, not the size of the source.
- Run the profile's `verify.ui` check for anything a user sees in the browser.
