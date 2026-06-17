import SwiftUI

// andross deliberately reads as "I am Android", so it themes away from reef:
// Android green on a slate ground. Same role taxonomy, different values — this
// is exactly what the themeable protocol is for. The literal hex is lifted
// from andross's existing `Color.androidGreen` / `slate*` palette.
public extension Color {
    static let androidGreen = Color(hex: 0x3DDC84)
    static let slateDeep    = Color(hex: 0x12171A)
    static let slateGround  = Color(hex: 0x1A2225)
    static let slateBorder  = Color(hex: 0x2A353A)
    static let slateTextDim = Color(hex: 0x8C9C9E)
    static let slateRed     = Color(hex: 0xFF5F56)
}

/// andross's "thin Android" look: Android green on slate.
public struct AndrossTheme: CVERTheme {
    public init() {}
    public var ground:    Color { .slateDeep }
    public var deep:      Color { .slateGround }
    public var accent:    Color { .androidGreen }
    public var highlight: Color { .androidGreen }
    public var onAccent:  Color { .slateDeep }
    public var text:      Color { .white }
    public var textDim:   Color { .slateTextDim }
    public var border:    Color { Color.white.opacity(0.12) }
    public var positive:  Color { .androidGreen }
    public var warning:   Color { Color(hex: 0xF5A623) }
    public var danger:    Color { .slateRed }
}
