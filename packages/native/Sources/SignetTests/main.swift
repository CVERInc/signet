import Signet
import SwiftUI

// Framework-free smoke runner (`swift run SignetTests`) — the family
// convention. A design system is mostly visual, so this just guards the
// invariants that CAN break silently: token ordering, hex parsing, and that
// both shipped themes satisfy the full role set.

var failures = 0
func check(_ label: String, _ ok: Bool) {
    print(ok ? "✓ \(label)" : "✗ \(label)")
    if !ok { failures += 1 }
}

// Radius ladder is strictly increasing — a swapped rung silently de-tunes the UI.
check("radius ladder ascends",
      CVERRadius.chip < CVERRadius.control
   && CVERRadius.control < CVERRadius.card
   && CVERRadius.card < CVERRadius.panel
   && CVERRadius.panel <= CVERRadius.window)

check("spacing ladder ascends",
      CVERSpacing.xs < CVERSpacing.sm
   && CVERSpacing.sm < CVERSpacing.md
   && CVERSpacing.md < CVERSpacing.lg
   && CVERSpacing.lg < CVERSpacing.xl
   && CVERSpacing.xl < CVERSpacing.xxl)

// Hex string parser: valid round-trips, garbage degrades to clear (no crash).
check("hex string valid parses", Color(hex: "#0a8c8e") != Color.clear)
check("hex string uppercase parses", Color(hex: "#0A8C8E") != Color.clear)
check("hex string no-# parses", Color(hex: "0a8c8e") != Color.clear)
check("hex string invalid → clear", Color(hex: "nope") == Color.clear)
// Length edge cases (3/8-digit unsupported, only RRGGBB is promised).
check("hex 3-digit → clear", Color(hex: "#abc") == Color.clear)
check("hex 8-digit → clear", Color(hex: "#0a8c8eff") == Color.clear)
check("hex empty → clear", Color(hex: "") == Color.clear)
check("hex bare # → clear", Color(hex: "#") == Color.clear)
// Signed-integer leak: UInt32(_:radix:) accepts a leading sign, so a 6-char
// string like "+abcde"/"-abcde" used to slip past the length check and parse
// as a real color. Must degrade to clear.
check("hex +sign → clear", Color(hex: "+abcde") == Color.clear)
check("hex -sign → clear", Color(hex: "-abcde") == Color.clear)
check("hex +sign no-# → clear", Color(hex: "+0a8c8") == Color.clear)
// Fullwidth/non-ASCII digits must not count as hex.
check("hex fullwidth → clear", Color(hex: "ＡＢＣＤＥＦ") == Color.clear)
check("hex trailing space → clear", Color(hex: "abcde ") == Color.clear)
// UInt32 init round-trips component extraction.
check("hex UInt32 black", Color(hex: 0x000000) != Color.clear)  // valid (clear has 0 alpha; this is opaque black)
check("hex UInt32 != string-clear", Color(hex: 0x0a8c8e) == Color(hex: "0a8c8e"))

// Both themes are usable existentials with every role wired (compile-time
// guarantee via protocol; this just exercises instantiation).
let themes: [any CVERTheme] = [ReefTheme(), AndrossTheme()]
check("themes instantiate", themes.count == 2)
check("reef accent is teal", ReefTheme().accent == Color.reefTeal)
check("andross accent is green", AndrossTheme().accent == Color.androidGreen)

// Theme parity: every role on every shipped theme must resolve to a real,
// non-clear color. A forgotten role would default to .clear and vanish.
func allRoles(_ t: any CVERTheme) -> [Color] {
    [t.ground, t.deep, t.accent, t.highlight, t.onAccent, t.text,
     t.textDim, t.border, t.positive, t.warning, t.danger]
}
for t in themes {
    let name = String(describing: type(of: t))
    check("\(name): no role is clear", allRoles(t).allSatisfy { $0 != Color.clear })
    check("\(name): 11 roles wired", allRoles(t).count == 11)
}
// The two shipped themes must actually look different (they're the whole point
// of having a protocol) — assert a few load-bearing roles diverge.
check("reef vs andross ground differs", ReefTheme().ground != AndrossTheme().ground)
check("reef vs andross accent differs", ReefTheme().accent != AndrossTheme().accent)

// Window position persistence validation (pure geometry, no NSWindow).
check("origin: valid dict restores",
      SignetWindowGeometry.restoredOrigin(from: ["x": 100.0, "topY": 500.0],
                                          windowHeight: 200) == CGPoint(x: 100, y: 300))
check("origin: missing keys → nil",
      SignetWindowGeometry.restoredOrigin(from: [:], windowHeight: 200) == nil)
check("origin: wrong type → nil",
      SignetWindowGeometry.restoredOrigin(from: ["x": "oops", "topY": 500.0],
                                          windowHeight: 200) == nil)
check("origin: NaN x → nil",
      SignetWindowGeometry.restoredOrigin(from: ["x": Double.nan, "topY": 500.0],
                                          windowHeight: 200) == nil)
check("origin: +Inf topY → nil",
      SignetWindowGeometry.restoredOrigin(from: ["x": 100.0, "topY": Double.infinity],
                                          windowHeight: 200) == nil)
check("origin: NaN windowHeight → nil",
      SignetWindowGeometry.restoredOrigin(from: ["x": 100.0, "topY": 500.0],
                                          windowHeight: CGFloat.nan) == nil)

// App-icon pipeline: a solid foreground → squircle master → PNG + .icns on disk.
do {
    let fg = NSImage(size: NSSize(width: 256, height: 256))
    fg.lockFocus(); NSColor.systemTeal.setFill(); NSRect(x: 0, y: 0, width: 256, height: 256).fill(); fg.unlockFocus()
    let master = CVERAppIcon.compose(foreground: fg, canvas: 256, contentInset: 18)
    check("appicon: compose master is 256px", Int(master.size.width) == 256)
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("signet-icon-smoke-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let png = dir.appendingPathComponent("icon.png")
    let icns = dir.appendingPathComponent("icon.icns")
    try CVERAppIcon.writePNG(master, to: png)
    try CVERAppIcon.writeICNS(master: master, to: icns)
    let pngSize = (try? FileManager.default.attributesOfItem(atPath: png.path))?[.size] as? Int ?? 0
    let icnsSize = (try? FileManager.default.attributesOfItem(atPath: icns.path))?[.size] as? Int ?? 0
    check("appicon: PNG written non-empty", pngSize > 0)
    check("appicon: .icns written non-empty", icnsSize > 0)
} catch {
    check("appicon: pipeline ran without throwing", false)
}

print(failures == 0 ? "\nAll Signet smoke checks passed." : "\n\(failures) check(s) FAILED.")
exit(failures == 0 ? 0 : 1)
