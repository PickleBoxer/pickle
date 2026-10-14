---
stack: swift
packs: [swift]
conventions: []
gates: [signing and provisioning, App Store Connect, release builds, Core Data or SwiftData model migrations]
---

## Verify

- test: <test>
- types: <types>
- lint: <lint>
- ui: <ui>

<!-- Setup notes, removed when the profile is written:
- Replace <scheme> with a scheme from `xcodebuild -list`, and <device> with a simulator from `xcrun simctl list devices available`. Never leave a placeholder in the written profile.
- A Swift package without an app has no ui line.
- ui for an iOS app is the simulator, for a macOS app running the app.
-->
