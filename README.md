# Signet

The shared design system for [CVER](https://cver.net)'s native macOS apps —
snapsift, clioil, reepub, andross, and the rest. One source of truth for the
palette, design tokens, glass surfaces, components, and the borderless
"liquid glass" window chrome, so every app renders as the same family.

The name is the metaphor: a signet stamps CVER's identity onto each app. The
*aesthetic* will follow the times (today's liquid glass won't be forever), but
the seal — the family identity — stays. That's also why the public API keeps a
brand-stable `CVER*` prefix (`CVERTheme`, `CVERRadius`, `.cverTheme`) while the
package is named `Signet`: if this package is ever renamed in a future design
era, app code changes one `import` line, not every call site.

This came out of a real observation: every CVER app had independently grown the
*same* color role taxonomy — `ground / deep / accent / highlight / text /
border` plus `positive / warning / danger` — and just drifted on the hex values
and the plumbing. Signet collapses that drift into one package.

## What's inside

| Area | API | Notes |
|---|---|---|
| Color hex | `Color(hex: 0x0a8c8e)`, `Color(hex: "#0a8c8e")` | one canonical init (replaces three drifted copies) |
| Theme | `CVERTheme` protocol, `ReefTheme` (default), `AndrossTheme` | inject via `.cverTheme(_:)`, read via `@Environment(\.cverTheme)` |
| Palette | `Color.reef*`, `Color.androidGreen` / `.slate*` | static constants for drop-in migration |
| Tokens | `CVERRadius`, `CVERSpacing` | a real ladder, not magic numbers |
| Typography | `.cverWordmark()` | lowercase + monospaced + bold house wordmark |
| Surfaces | `.liquidGlassCard()`, `.cverPanel()` | frosted glass for chrome; opaque for content |
| Components | `.buttonStyle(.cver())`, `.cverBanner(_:)`, `CVERGate` | the repeated UI, factored out |
| Window | `.glassWindowChrome()` | borderless rounded frosted window (opt-in) |

## Adding it

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/CVERInc/signet", branch: "main"),
],
targets: [
    .executableTarget(name: "MyApp", dependencies: [
        .product(name: "Signet", package: "signet"),
    ]),
]
```

```swift
import Signet

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView().cverTheme(ReefTheme()) }
    }
}
```

CVER apps pin in-house deps to `branch: "main"` / latest — see the family
convention — so improvements land everywhere on the next build.

## The one rule worth repeating

`.liquidGlassCard()` is for **chrome** — sidebars, toolbars, cards, overlays.
Do **not** put glass behind a canvas where color accuracy matters (e.g.
snapsift's photo grid): glass lets the desktop bleed through and shifts
perceived color. Glass chrome, opaque content.

## Building

`swift build` · `swift run SignetTests` (framework-free smoke runner). Pinned to
swift-tools 5.9 / macOS 13 so every CVER app can depend on it.
