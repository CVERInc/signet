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
check("hex string invalid → clear", Color(hex: "nope") == Color.clear)

// Both themes are usable existentials with every role wired (compile-time
// guarantee via protocol; this just exercises instantiation).
let themes: [any CVERTheme] = [ReefTheme(), AndrossTheme()]
check("themes instantiate", themes.count == 2)
check("reef accent is teal", ReefTheme().accent == Color.reefTeal)
check("andross accent is green", AndrossTheme().accent == Color.androidGreen)

print(failures == 0 ? "\nAll Signet smoke checks passed." : "\n\(failures) check(s) FAILED.")
exit(failures == 0 ? 0 : 1)
