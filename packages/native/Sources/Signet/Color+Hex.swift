import SwiftUI

// One canonical Color(hex:) for the whole family. Until now snapsift/clioil
// used `Color(hex: UInt32)`, andross used `Color(hex: UInt)`, and reepub used
// `Color(hex: "#string")` — three drifted copies of the same idea. This is the
// single definition everyone imports.
public extension Color {
    /// `Color(hex: 0x0a8c8e)` — the canonical form (snapsift/clioil already use it).
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// `Color(hex: "#0a8c8e")` — string convenience so reepub-style call sites
    /// migrate with no rewrite. Accepts an optional leading `#`. Invalid strings
    /// fall back to clear rather than crashing.
    init(hex string: String, opacity: Double = 1) {
        let cleaned = string.hasPrefix("#") ? String(string.dropFirst()) : string
        // Require EXACTLY six hex digits. `UInt32(_:radix:)` alone is too
        // permissive — it accepts a leading sign (`"+abcde"`, `"-abcde"`), so
        // the length check is not enough to reject malformed input. Validate
        // the character set ourselves so only true `RRGGBB` parses.
        let isSixHexDigits = cleaned.count == 6
            && cleaned.allSatisfy { $0.isHexDigit && $0.isASCII }
        if isSixHexDigits, let value = UInt32(cleaned, radix: 16) {
            self.init(hex: value, opacity: opacity)
        } else {
            self = .clear
        }
    }
}
