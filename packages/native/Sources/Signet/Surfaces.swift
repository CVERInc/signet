import SwiftUI

// The signature CVER surface, generalized from andross's `liquidGlassBackground`
// and themed. Frosted material + a faint white lift + a hairline border on a
// continuous-corner rectangle. The border defaults to the theme's border color.
//
// ⚠️ Use this for *chrome* (sidebars, toolbars, cards, overlays) — NOT for a
// canvas where color accuracy matters (e.g. snapsift's photo grid). Glass lets
// the desktop bleed through and shifts perceived color; keep content surfaces
// opaque. This is a hard line for snapsift (its DNA is accuracy, not vibe).
public extension View {
    func liquidGlassCard(cornerRadius: CGFloat = CVERRadius.card, border: Color? = nil) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, border: border))
    }

    /// Opaque themed panel — the safe surface for content that must read true.
    func cverPanel(cornerRadius: CGFloat = CVERRadius.card, fill: KeyPath<any CVERTheme, Color>? = nil) -> some View {
        modifier(CVERPanel(cornerRadius: cornerRadius, fill: fill))
    }
}

private struct LiquidGlassCard: ViewModifier {
    @Environment(\.cverTheme) private var theme
    let cornerRadius: CGFloat
    let border: Color?

    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.05))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(border ?? theme.border, lineWidth: 1)
            )
    }
}

private struct CVERPanel: ViewModifier {
    @Environment(\.cverTheme) private var theme
    let cornerRadius: CGFloat
    let fill: KeyPath<any CVERTheme, Color>?

    func body(content: Content) -> some View {
        let color = fill.map { theme[keyPath: $0] } ?? theme.deep
        return content
            .background(color, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(theme.border, lineWidth: 1)
            )
    }
}
