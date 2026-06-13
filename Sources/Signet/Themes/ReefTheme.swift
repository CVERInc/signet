import SwiftUI

// The canonical reef palette — the literal hex snapsift and clioil already
// shipped. Exposed as static `Color.reef*` so those apps migrate by deleting
// their local Theme.swift and `import CVERKit` — zero call-site churn. reepub
// (which used drifted names/string-hex) consolidates onto these too.
public extension Color {
    static let reefGround  = Color(hex: 0x04181a)            // deep teal-black
    static let reefDeep    = Color(hex: 0x052f30)            // panels / sidebar
    static let reefTeal    = Color(hex: 0x0a8c8e)            // primary accent
    static let reefMint    = Color(hex: 0xaceace)            // headings / highlights
    static let reefText    = Color(hex: 0xe6f4f3)            // primary text
    static let reefTextDim  = Color(hex: 0xe6f4f3, opacity: 0.62)
    static let reefBorder   = Color(hex: 0xaceace, opacity: 0.18)
    static let reefGreen   = Color(hex: 0x10b981)            // keep / clean
    static let reefAmber   = Color(hex: 0xf59e0b)            // warning
    static let reefRed     = Color(hex: 0xef4444)            // delete / error
}

/// The default CVER look: deep teal ground, mint headings, teal accent.
public struct ReefTheme: CVERTheme {
    public init() {}
    public var ground:    Color { .reefGround }
    public var deep:      Color { .reefDeep }
    public var accent:    Color { .reefTeal }
    public var highlight: Color { .reefMint }
    public var onAccent:  Color { .reefGround }   // dark text on mint/teal fills
    public var text:      Color { .reefText }
    public var textDim:   Color { .reefTextDim }
    public var border:    Color { .reefBorder }
    public var positive:  Color { .reefGreen }
    public var warning:   Color { .reefAmber }
    public var danger:    Color { .reefRed }
}
