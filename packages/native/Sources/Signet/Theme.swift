import SwiftUI

// The role taxonomy. Every CVER app already used exactly these roles — reef
// (snapsift/clioil/reepub) and slate+green (andross) are the SAME structure
// with different hex. A theme just supplies the values; views ask for roles,
// never raw colors. Swap the theme → reskin the whole app.
//
// Web analogy: this protocol is your `tokens.css` contract; ReefTheme /
// AndrossTheme are two `:root` variable sets that satisfy it.
public protocol CVERTheme: Sendable {
    var ground:   Color { get }   // window background
    var deep:     Color { get }   // panels / sidebar / cards
    var accent:   Color { get }   // primary action / selection (reef teal, andross green)
    var highlight: Color { get }  // headings / emphasis (reef mint)
    var onAccent: Color { get }   // text & icons sitting on an accent/highlight fill
    var text:     Color { get }   // primary text
    var textDim:  Color { get }   // secondary text
    var border:   Color { get }   // hairline strokes / dividers
    var positive: Color { get }   // success / keep / clean (green)
    var warning:  Color { get }   // caution (amber)
    var danger:   Color { get }   // destructive / error (red)
}

// MARK: - Environment injection (the SwiftUI equivalent of CSS cascade)

private struct CVERThemeKey: EnvironmentKey {
    static let defaultValue: any CVERTheme = ReefTheme()
}

public extension EnvironmentValues {
    var cverTheme: any CVERTheme {
        get { self[CVERThemeKey.self] }
        set { self[CVERThemeKey.self] = newValue }
    }
}

public extension View {
    /// Inject a theme at the root; every descendant reads it via
    /// `@Environment(\.cverTheme)`. Call once near your top-level view.
    func cverTheme(_ theme: any CVERTheme) -> some View {
        environment(\.cverTheme, theme)
    }
}
