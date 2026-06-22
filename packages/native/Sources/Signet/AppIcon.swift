import AppKit
import SceneKit

/// The shared macOS app-icon pipeline: render → squircle → iconset/.icns. Extracted
/// so every CVER app mints its icon the same way — the app supplies only its own
/// artwork (an `NSImage`, or an `SCNScene` to render); Signet owns the Apple-style
/// squircle, sheen, the full size set, and the `.icns` packaging.
///
/// Brand-stable `CVER*` name (see Package.swift): app code is insulated from a future
/// rename of the package itself.
public enum CVERAppIcon {

    public enum Failure: Error { case encodeFailed, iconutilFailed(Int32) }

    // MARK: Render artwork

    /// Offscreen-render an `SCNScene` to a square `NSImage` — the icon foreground.
    /// `pointOfView` defaults to the scene's current camera.
    public static func render(scene: SCNScene,
                              pointOfView: SCNNode? = nil,
                              size: CGFloat,
                              antialiasing: SCNAntialiasingMode = .multisampling4X) -> NSImage {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer.scene = scene
        if let pov = pointOfView { renderer.pointOfView = pov }
        return renderer.snapshot(atTime: 0,
                                 with: CGSize(width: size, height: size),
                                 antialiasingMode: antialiasing)
    }

    // MARK: Compose the icon master

    /// Compose `foreground` into a square icon master, masked to the macOS squircle.
    /// - `canvas`: master size in px (1024 for App Store / .icns).
    /// - `contentInset`: margin (px) around the artwork inside the canvas.
    /// - `cornerRatio`: corner radius ÷ content width (≈0.224 ≈ Apple's look).
    /// - `sheen`: a faint top-down gloss; `background`: optional fill behind artwork.
    public static func compose(foreground: NSImage,
                               canvas: CGFloat = 1024,
                               contentInset: CGFloat = 72,
                               cornerRatio: CGFloat = 0.224,
                               sheen: Bool = true,
                               background: NSColor? = nil) -> NSImage {
        let rep = bitmap(px: Int(canvas))
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let rect = NSRect(x: contentInset, y: contentInset,
                          width: canvas - 2 * contentInset, height: canvas - 2 * contentInset)
        let r = rect.width * cornerRatio
        let path = NSBezierPath(roundedRect: rect, xRadius: r, yRadius: r)
        path.addClip()
        if let background { background.setFill(); path.fill() }
        foreground.draw(in: rect)
        if sheen {
            NSGradient(starting: NSColor(white: 1, alpha: 0.10), ending: NSColor(white: 1, alpha: 0))?
                .draw(in: rect, angle: 90)
        }
        NSGraphicsContext.restoreGraphicsState()
        let image = NSImage(size: NSSize(width: canvas, height: canvas))
        image.addRepresentation(rep)
        return image
    }

    // MARK: Write outputs

    /// PNG-encode and write an image at its native pixel size.
    public static func writePNG(_ image: NSImage, to url: URL) throws {
        guard let png = pngData(image) else { throw Failure.encodeFailed }
        try png.write(to: url)
    }

    /// Write a full `.iconset` folder (every standard macOS size, 1x + 2x) from a master.
    @discardableResult
    public static func writeIconSet(master: NSImage, to dir: URL) throws -> URL {
        let fm = FileManager.default
        try? fm.removeItem(at: dir)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        for base in [16, 32, 64, 128, 256, 512] {
            for (scale, suffix) in [(1, ""), (2, "@2x")] {
                guard let png = pngData(master, px: base * scale) else { throw Failure.encodeFailed }
                try png.write(to: dir.appendingPathComponent("icon_\(base)x\(base)\(suffix).png"))
            }
        }
        return dir
    }

    /// Build a `.icns` from a master (writes a temp `.iconset`, runs `iconutil`).
    public static func writeICNS(master: NSImage, to url: URL) throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("CVERAppIcon-\(UUID().uuidString).iconset")
        try writeIconSet(master: master, to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        p.arguments = ["-c", "icns", tmp.path, "-o", url.path]
        try p.run()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { throw Failure.iconutilFailed(p.terminationStatus) }
    }

    /// One-shot: scene → squircle master → write both a 1024 PNG and an `.icns`.
    public static func build(scene: SCNScene,
                             pointOfView: SCNNode? = nil,
                             pngURL: URL?,
                             icnsURL: URL?,
                             canvas: CGFloat = 1024,
                             contentInset: CGFloat = 72,
                             cornerRatio: CGFloat = 0.224,
                             sheen: Bool = true,
                             background: NSColor? = nil) throws {
        let fg = render(scene: scene, pointOfView: pointOfView, size: canvas - 2 * contentInset)
        let master = compose(foreground: fg, canvas: canvas, contentInset: contentInset,
                             cornerRatio: cornerRatio, sheen: sheen, background: background)
        if let pngURL { try writePNG(master, to: pngURL) }
        if let icnsURL { try writeICNS(master: master, to: icnsURL) }
    }

    // MARK: - Internals

    private static func bitmap(px: Int) -> NSBitmapImageRep {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                   isPlanar: false, colorSpaceName: .deviceRGB,
                                   bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = NSSize(width: px, height: px)
        return rep
    }

    /// PNG bytes for `image` rendered at an exact pixel size (defaults to the image's).
    private static func pngData(_ image: NSImage, px: Int? = nil) -> Data? {
        let size = px ?? Int(image.size.width)
        let rep = bitmap(px: size)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])
    }
}
