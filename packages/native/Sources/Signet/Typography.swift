import SwiftUI

// The CVER wordmark is always lowercase + monospaced + bold (snapsift, andross,
// clikae all do this by hand). One helper so it's identical everywhere and the
// brand color comes from the theme.
public extension View {
    /// Render an app's lowercase wordmark in the house style.
    /// `Text("snapsift").cverWordmark()`
    func cverWordmark(size: CGFloat? = nil) -> some View {
        modifier(CVERWordmark(size: size))
    }
}

private struct CVERWordmark: ViewModifier {
    @Environment(\.cverTheme) private var theme
    let size: CGFloat?

    func body(content: Content) -> some View {
        content
            .font(size.map { .system(size: $0, weight: .bold, design: .monospaced) }
                  ?? .system(.headline, design: .monospaced).weight(.bold))
            .foregroundStyle(theme.accent)
    }
}
