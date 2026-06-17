import CoreGraphics

// A real ladder, not the ad-hoc 4/6/8/12/14/30/44/55 that andross accumulated.
// Pick a rung by role, never a magic number — that's what keeps every app's
// corners and gaps visually consistent. (Web analogy: your spacing/radius
// design tokens — `--radius-card`, `--space-md`.)

/// Corner radii. `style: .continuous` (Apple's squircle) is assumed everywhere.
public enum CVERRadius {
    public static let chip:    CGFloat = 6    // tags, small pills, thumbnails
    public static let control: CGFloat = 10   // buttons, fields, segmented
    public static let card:    CGFloat = 16   // cards, list rows, popovers
    public static let panel:   CGFloat = 20   // large surfaces, sheets
    public static let window:  CGFloat = 22   // borderless window corner (was 55 — too phone-like for desktop)
}

/// Spacing scale for padding and stack spacing.
public enum CVERSpacing {
    public static let xs:  CGFloat = 4
    public static let sm:  CGFloat = 8
    public static let md:  CGFloat = 12
    public static let lg:  CGFloat = 16
    public static let xl:  CGFloat = 24
    public static let xxl: CGFloat = 32
}
