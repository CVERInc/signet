// swift-tools-version: 5.9
import PackageDescription

// Signet — the shared design system for CVER's native macOS apps
// (snapsift, clioil, reepub, andross, …). One source of truth for the
// palette, design tokens, glass surfaces, components, and the borderless
// "liquid glass" window chrome, so every app renders as the same family.
//
// The package/module is named `Signet` (the seal CVER stamps on each app),
// but the public API keeps the brand-stable `CVER*` prefix (`CVERTheme`,
// `CVERRadius`, `.cverTheme`, …) — so even if this package is renamed in a
// future design era, app code only changes one `import` line.
//
// Pinned to swift-tools-version 5.9 (snapsift's floor) and macOS 13
// (clioil/andross's floor) so EVERY app can depend on it. A 5.9 package
// consumed by a 6.0 package compiles in Swift 5 mode — which conveniently
// keeps the AppKit window code out of Swift 6's strict Sendable checking.
let package = Package(
    name: "Signet",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Signet", targets: ["Signet"]),
    ],
    targets: [
        .target(name: "Signet"),
        // Dependency-free smoke runner (`swift run SignetTests`) — the family
        // convention, since Command Line Tools ship no XCTest/swift-testing.
        .executableTarget(name: "SignetTests", dependencies: ["Signet"]),
    ]
)
