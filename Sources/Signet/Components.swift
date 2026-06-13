import SwiftUI

// MARK: - Button styles

/// The house button. `.buttonStyle(.cver())` for the accent action,
/// `.buttonStyle(.cver(.danger))` for destructive, `.cver(.ghost)` for quiet.
public struct CVERButtonStyle: ButtonStyle {
    public enum Kind: Sendable { case primary, danger, ghost }
    let kind: Kind

    public func makeBody(configuration: Configuration) -> some View {
        CVERButtonBody(kind: kind, configuration: configuration)
    }
}

private struct CVERButtonBody: View {
    @Environment(\.cverTheme) private var theme
    let kind: CVERButtonStyle.Kind
    let configuration: ButtonStyleConfiguration

    var body: some View {
        let (bg, fg): (Color, Color) = {
            switch kind {
            case .primary: return (theme.accent, theme.onAccent)
            case .danger:  return (theme.danger, .white)
            case .ghost:   return (theme.deep, theme.text)
            }
        }()
        return configuration.label
            .font(.callout.weight(.semibold))
            .padding(.horizontal, CVERSpacing.lg)
            .padding(.vertical, CVERSpacing.sm)
            .background(bg, in: RoundedRectangle(cornerRadius: CVERRadius.control, style: .continuous))
            .foregroundStyle(fg)
            .overlay(
                kind == .ghost
                    ? RoundedRectangle(cornerRadius: CVERRadius.control, style: .continuous)
                        .strokeBorder(theme.border, lineWidth: 1)
                    : nil
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == CVERButtonStyle {
    static func cver(_ kind: CVERButtonStyle.Kind = .primary) -> CVERButtonStyle {
        CVERButtonStyle(kind: kind)
    }
}

// MARK: - Status banner

public extension View {
    /// A transient capsule banner that slides in from the top — the pattern
    /// snapsift/andross both use after an action ("Deleted 12 photos").
    /// Pass `nil` to hide. Animate the bound state at the call site.
    func cverBanner(_ message: String?) -> some View {
        overlay(alignment: .top) {
            if let message {
                CVERBannerView(message: message)
                    .padding(.top, CVERSpacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

private struct CVERBannerView: View {
    @Environment(\.cverTheme) private var theme
    let message: String

    var body: some View {
        Text(message)
            .font(.callout)
            .foregroundStyle(theme.onAccent)
            .padding(.horizontal, CVERSpacing.lg)
            .padding(.vertical, CVERSpacing.sm + 2)
            .background(theme.accent, in: Capsule())
    }
}

// MARK: - Permission / empty-state gate

/// A centered title + message + optional action — the shape snapsift uses for
/// its Photos permission gate, and any "we need X to continue" screen.
public struct CVERGate: View {
    @Environment(\.cverTheme) private var theme
    let wordmark: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    public init(wordmark: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.wordmark = wordmark
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: CVERSpacing.lg) {
            Text(wordmark).cverWordmark(size: 30)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textDim)
                .frame(maxWidth: 440)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.cver())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.ground)
    }
}
