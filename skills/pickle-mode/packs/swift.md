<!-- TODO: written from memory, not checked against docs. Verify every command, API and version claim against the official docs, then delete this comment. Least certain: typed `throws(...)`, `swift format lint`, `confirmation` and `#require` in Swift Testing, `@Attribute(.unique)`, `swift package reset`, `-strict-concurrency=complete`, the swift-lsp server. -->

# Swift pack

The Swift half of the principles, plus default verify commands and the language server. Each section gives only the Swift form of one principle: read the principle file first, then apply it with the lines below. Lines marked SwiftUI apply to app targets that use it.

## Verify commands

The profile's verify commands win. Without a profile, use the first that fits the project:

| Purpose | Command |
|---|---|
| test | `swift test` for a `Package.swift` package. For an Xcode project: `xcodebuild test -scheme <scheme> -destination 'platform=iOS Simulator,name=<device>'` |
| types | `swift build`, or `xcodebuild build` with the same scheme. The compiler is the type checker |
| lint | `swiftlint`, `swift format lint --recursive .` |

Read the scheme and a simulator name from `xcodebuild -list` and `xcrun simctl list devices available`, never guess them. Run one test (`swift test --filter`, `-only-testing:`) while iterating, the full suite before saying done.

## Language server

With SourceKit-LSP, the LSP tool finds definitions and references and reports compiler errors after edits, more reliably than grep. If the LSP tool is not available for `.swift` files, suggest it once in the reply. Do not install it.

- `swift-lsp@claude-plugins-official`. Server: `sourcekit-lsp`, which ships with Xcode and the Swift toolchain.

## principle-types

- A closed set is an `enum`, with associated values for data that only some cases have.
- `switch` over the project's own enums has no `default`, so a new case fails to compile. `@unknown default` only for enums from other modules that may grow.
- Distinct meanings get their own type, `struct OrderID: Hashable { let rawValue: UUID }`, not a bare `UUID` or `String`.
- Value types (`struct`, `enum`) by default. A `class` needs a reason: identity, or shared mutable state behind an actor.
- `!`, `try!` and `as!` are lies to the checker outside tests. Unwrap with `guard let` and handle the failure at a boundary.

## principle-boundaries

- Network and file data decode with `Codable` into transfer types at the edge, then map to domain types. Views and domain code never see raw JSON.
- Errors are a domain `enum` conforming to `Error`, thrown with typed `throws(OrderError)` where the project's Swift version has it. No `try?` that turns a failure into a silent `nil`.
- Services sit behind a protocol the app owns and are injected, so tests pass a fake.
- SwiftUI: views read state and send intents to an `@Observable` model. No networking or persistence inside a view body.

## principle-model-the-domain

- Screen and request state as one enum, `enum LoadState { case idle, loading, loaded(Order), failed(OrderError) }`, not `isLoading`, `error` and `order` optionals that must stay in sync.
- Transitions live in one method on the model (`order.cancel()`), not in view code.

## principle-idempotent-operations

- Actors are re-entrant across `await`. After every `await` inside an actor, recheck the state before acting on what was read before it.
- A `Task` can be cancelled or started twice (a view appearing again). Check `Task.isCancelled`, keep the task handle, and cancel or reuse it instead of starting a duplicate.
- Persistence converges with a unique key (`@Attribute(.unique)` in SwiftData, a uniqueness constraint in Core Data) instead of insert-if-missing in code.
- Retried requests that change server state carry an idempotency key.

## principle-no-shared-writes

- Swift 6 language mode, or `-strict-concurrency=complete`, makes the compiler reject data races. Keep it on.
- Shared mutable state lives in one actor or on `@MainActor`. Prefer passing values over sharing references.
- `nonisolated(unsafe)` and `@unchecked Sendable` are lies to the checker. Each one needs a reason in a comment and a plan to remove it.

## principle-test-behavior

- Swift Testing: `@Test` functions with `#expect(order.status == .shipped)` on a literal, and `#require` to unwrap. Parameterized inputs with `@Test(arguments:)`.
- Async events: `confirmation`, asserting the payload the fake received, not only that it was called.
- UI flows: XCUITest drives the app through accessibility identifiers and asserts what is on screen.

## principle-fix-root-causes

- Reproduce with a failing test before the fix.
- Read the real crash: the symbolicated log, the exception breakpoint, the actual error value. Enable Thread Sanitizer for crashes that move around.
- "Works on my machine", "fails after switching branches": suspect stale build state. Clean the build folder, `swift package reset` for package caches, erase the simulator for leftover app data.
- Remove debugging `print` calls before saying done.

## principle-finish-migrations

- Mark the old API `@available(*, deprecated, renamed: "newName")`. The compiler then lists every caller as a warning, and Xcode offers the rename.
- Find the rest with LSP references and grep for string forms: notification names, storyboard identifiers, `UserDefaults` keys.
- Migrate completion handlers to `async` and Swift 6 concurrency one module at a time, each module building cleanly before the next.

## principle-prove-it-works

- Measure a Release build on a device with Instruments (Time Profiler, Allocations), not a Debug build in the simulator.
- Timing in tests: `ContinuousClock` over many iterations, or XCTest `measure`, with the spread.
- Run the profile's `verify.ui` check in the simulator for anything a user sees.
