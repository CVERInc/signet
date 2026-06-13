import SwiftUI
import AppKit

// The borderless "liquid glass" window chrome, extracted from andross and made
// reusable. It turns the host NSWindow borderless, wraps its content in a
// frosted NSVisualEffectView with continuous-rounded corners + a hairline
// border, makes the whole surface draggable, and (optionally) remembers its
// position. The andross-specific forced phone-resize is intentionally removed —
// here the window keeps SwiftUI's natural size and stays user-resizable.
//
// ⚠️ Hard-won gotchas (paid for in andross — don't relearn them):
//   • A custom borderless NSWindow refuses AX set-position. UI automation can't
//     move it — screenshot tests must capture full-screen + crop.
//   • Standard window management (Stage Manager, tiling) gets fuzzy on
//     borderless windows. This trades macOS-native window behavior for looks —
//     right for a phone-like shell (andross), a real tradeoff for a dense
//     desktop tool. Make it opt-in per app, not the default.
public extension View {
    /// Apply borderless liquid-glass chrome to the hosting window.
    /// - Parameters:
    ///   - cornerRadius: window corner (defaults to the desktop-sane 22, not andross's phone-like 55).
    ///   - rememberPositionKey: if set, persist/restore the window origin under this UserDefaults namespace.
    func glassWindowChrome(cornerRadius: CGFloat = CVERRadius.window,
                           rememberPositionKey: String? = nil) -> some View {
        background(GlassWindowConfigurator(cornerRadius: cornerRadius,
                                           rememberPositionKey: rememberPositionKey))
    }
}

private struct GlassWindowConfigurator: NSViewRepresentable {
    let cornerRadius: CGFloat
    let rememberPositionKey: String?

    func makeNSView(context: Context) -> NSView {
        let v = GlassConfiguratorView()
        v.cornerRadius = cornerRadius
        v.rememberPositionKey = rememberPositionKey
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// Marker subclass so we never double-wrap the content view.
private final class CVERGlassView: NSVisualEffectView {}

private final class GlassConfiguratorView: NSView {
    var cornerRadius: CGFloat = CVERRadius.window
    var rememberPositionKey: String?
    private var isConfigured = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window = self.window, !isConfigured else { return }
        isConfigured = true

        configureWindow(window)
        wrapInGlass(window)
        restorePositionIfNeeded(window)

        NotificationCenter.default.addObserver(
            self, selector: #selector(savePositionIfNeeded),
            name: NSWindow.didMoveNotification, object: window)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: window flags

    private func configureWindow(_ window: NSWindow) {
        window.styleMask = [.borderless, .resizable]
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.invalidateShadow()
    }

    // MARK: glass wrapping

    private func wrapInGlass(_ window: NSWindow) {
        guard let original = window.contentView, !(original is CVERGlassView) else { return }

        let glass = CVERGlassView()
        glass.material = .hudWindow          // dark frosted blur — pairs with .dark color scheme
        glass.blendingMode = .behindWindow
        glass.state = .active
        glass.wantsLayer = true
        applyRounding(glass)

        window.contentView = glass
        glass.addSubview(original)
        original.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            original.leadingAnchor.constraint(equalTo: glass.leadingAnchor),
            original.trailingAnchor.constraint(equalTo: glass.trailingAnchor),
            original.topAnchor.constraint(equalTo: glass.topAnchor),
            original.bottomAnchor.constraint(equalTo: glass.bottomAnchor),
        ])

        // Hide AppKit's own background visual-effect views (siblings under NSThemeFrame),
        // otherwise they paint an opaque rectangle behind our rounded glass.
        if let root = glass.superview {
            for sub in root.subviews where sub !== glass {
                let name = String(describing: type(of: sub))
                if sub is NSVisualEffectView || name.contains("VisualEffectView") {
                    sub.isHidden = true
                }
            }
        }
    }

    private func applyRounding(_ glass: CVERGlassView) {
        let r = cornerRadius
        let mask = NSImage(size: NSSize(width: r * 2, height: r * 2), flipped: false) { rect in
            NSBezierPath(roundedRect: rect, xRadius: r, yRadius: r).fill()
            return true
        }
        mask.capInsets = NSEdgeInsets(top: r, left: r, bottom: r, right: r)
        mask.resizingMode = .stretch
        glass.maskImage = mask
        glass.layer?.cornerRadius = r
        glass.layer?.cornerCurve = .continuous
        glass.layer?.masksToBounds = true
        glass.layer?.borderWidth = 1
        glass.layer?.borderColor = NSColor(white: 1, alpha: 0.12).cgColor
    }

    // MARK: position memory (opt-in)

    private func restorePositionIfNeeded(_ window: NSWindow) {
        guard let key = rememberPositionKey,
              let dict = UserDefaults.standard.dictionary(forKey: key),
              let x = dict["x"] as? Double, let topY = dict["topY"] as? Double else { return }
        // Persist the TOP-left so windows of differing height re-anchor naturally.
        let origin = NSPoint(x: x, y: topY - window.frame.height)
        window.setFrameOrigin(origin)
    }

    @objc private func savePositionIfNeeded() {
        guard let key = rememberPositionKey, let window = self.window else { return }
        let f = window.frame
        UserDefaults.standard.set(["x": Double(f.origin.x),
                                   "topY": Double(f.origin.y + f.height)], forKey: key)
    }
}
