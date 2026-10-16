# Swift stack

Maps workflow skill steps to Swift commands and tools. Commands only; no Swift language skill exists yet, so follow the project's own conventions for idioms. The project's own commands win: CI workflows, a `Makefile` or `fastlane/Fastfile`, README and `CLAUDE.md`.

## Detect

- `Package.swift` means a Swift package. An `*.xcodeproj` or `*.xcworkspace` means an Xcode project, which can also depend on packages. Use the workspace when there is one.
- Schemes and targets: `xcodebuild -list`. Simulators: `xcrun simctl list devices available`.
- Test framework: `import Testing` is Swift Testing, `import XCTest` is XCTest. A project can use both.
- Linters: `.swiftlint.yml` means SwiftLint, `.swift-format` means swift-format.
- `xcodebuild` output is long. Pipe it through `xcbeautify` if installed, and read failures from the result bundle.

## Commands

`<dest>` below is `-destination 'platform=iOS Simulator,name=<device>'` with a device from `simctl list`. `swift` commands apply to packages, `xcodebuild` commands to Xcode projects.

| Step | Package | Xcode project |
|---|---|---|
| Build | `swift build` | `xcodebuild build -scheme <S> <dest>` |
| Full suite | `swift test` | `xcodebuild test -scheme <S> <dest>` |
| Focused test | `swift test --filter <Suite>/<test>` | `xcodebuild test -scheme <S> <dest> -only-testing:<Target>/<Class>/<method>` |
| Lint | `swiftlint lint --strict` | same |
| Format check | `swift format lint --strict --recursive .` | same |
| Types | the compiler; Swift 6 language mode adds strict concurrency checking | same |
| Coverage | `swift test --enable-code-coverage` | `-enableCodeCoverage YES -resultBundlePath R.xcresult`, then `xcrun xccov view --report R.xcresult` |
| CI resolve | `swift build --only-use-versions-from-resolved-file` | `xcodebuild -resolvePackageDependencies -onlyUsePackageVersionsFromResolvedFile` |
| Dependency audit | no native command | Dependabot (`package-ecosystem: "swift"`) |
| Build-time code | Package plugins and macros run at build time. Never pass `-skipPackagePluginValidation` or `-skipMacroValidation` without reviewing them | same |

Commit `Package.resolved`. It is the lockfile.

## UI checks

The web tools in `frontend-ui-engineering`, `browser-testing-with-devtools` and the accessibility checklist do not apply. Verify UI in the simulator, check accessibility with the Accessibility Inspector, or with `performAccessibilityAudit()` in a UI test.

## Performance

- Profile with Instruments: Time Profiler, Allocations, Leaks, Hangs. `xcrun xctrace record` runs it from the command line.
- Guard regressions with XCTest `measure(metrics:)`, for example `XCTClockMetric` or `XCTApplicationLaunchMetric`.
- Web bundle size and Lighthouse budgets do not apply. App size comes from the App Thinning size report.

## Shipping

- There is no instant rollback. A release goes through App Store review, and users update when they choose, so old versions stay in use.
- Ship through TestFlight first, then a phased release you can pause.
- Put risky features behind a remote flag or a server-side kill switch, so you can turn them off without a new build.
- The backend API must stay compatible with every app version still installed.
