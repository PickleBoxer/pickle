---
name: typescript-best-practices
description: Default TypeScript idioms (discriminated unions, branded types, no `as` casts, schemas at the boundary, exhaustive switches) that apply pickle's principles to .ts and .tsx code. Use when writing, editing or reviewing TypeScript and the pickle profile lists it as a convention, or when the project has no TypeScript conventions of its own. The project's own conventions win.
metadata:
  upstream: pstack/skills/typescript-best-practices
  upstream-version: 0.15.24
---

# TypeScript best practices

Defaults for TypeScript. The project's own conventions, `CLAUDE.md` and existing code win where they differ: follow them and say which rule you followed.

Each rule applies a pickle principle: the rule is how, the principle is why. A `**principle-<name>**` mention is the file `${CLAUDE_SKILL_DIR}/../pickle-mode/principles/<name>.md`. Examples for every rule: `${CLAUDE_SKILL_DIR}/references/patterns.md`.

| Rule | Summary | Principle |
|---|---|---|
| Discriminated unions | Model variants with one literal discriminant (`kind`) so impossible states cannot be written. No bags of optional fields. | **principle-model-the-domain** |
| Branded types | Brand primitives with `& { readonly __brand: "X" }` so they cannot be mixed up. Validate once at the boundary. | **principle-types** |
| Constructive modeling | Build the shape so the illegal value cannot exist: `[T, ...T[]]` for non-empty, `[T, T][]` for even length, start plus duration for a range. Not a runtime guard. | **principle-types** |
| Simplest total type | Keep `T[]` while every operation on it stays total. Strengthen only where the loose type forces `!`, a cast or a "should never happen" throw. | **principle-types** |
| `unknown` over `any` | External data is `unknown` until parsed. | **principle-boundaries** |
| Schemas before guards | Use the repo's runtime schema library and infer the type from the schema (`z.infer`) before hand-writing a guard. Add no schema dependency for one guard. | **principle-boundaries** |
| No `as` casts | Cast only after validation. Every other `as` is a runtime crash waiting. | **principle-types** |
| Narrowing order | Discriminant switch, then `in`, then `typeof` or `instanceof`, then a type guard, then `as`. | **principle-types** |
| Type guards | Name them `isX` or `hasX`, and make them check the whole claim. A lying guard is worse than `as`. | **principle-types** |
| Exhaustiveness | `const _exhaustive: never = x;` in default arms, so a new variant fails to compile. | **principle-types** |
| `satisfies` over `as` | Checks the value without widening literal types. | **principle-types** |
| Boundary validation | Parse where data crosses in, into a named domain type. `Record<string, unknown>` stops at that parse. Trust types inside. | **principle-boundaries** |
| Derived types | `Pick`, `Omit`, `Parameters`, `ReturnType`, `Awaited`, `typeof` and generated schema types before a new interface. | **principle-model-the-domain** |
| Object arguments | Pass an object, not positional arguments, so order cannot be swapped. Skip on hot paths (per-frame render, tokenizers, parsers). | **principle-minimize-reader-load** |
| Real tests | Do not mock what you can run. Use the framework's real test primitives, check UI in a running build, mock only what cannot run locally. | **principle-test-behavior** |
| Structured telemetry | The project's structured logger with enough context to debug from an id. No `console.log` in shipped code. | **principle-prove-it-works** |
