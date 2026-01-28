import AppKit
import CoreGraphics

/// A window that displays at the desktop level, below all other windows and desktop icons
class WallpaperWindow: NSWindow {

    init(for screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.setFrame(screen.frame, display: false)
        configureWindow()
    }

    private func configureWindow() {
        // Set window level to desktop level (below desktop icons)
        // kCGDesktopWindowLevel is approximately Int32.min + 25
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))

        // Window appearance
        isOpaque = true
        hasShadow = false
        backgroundColor = .black

        // Interaction settings
        ignoresMouseEvents = true  // Let clicks pass through to desktop
        acceptsMouseMovedEvents = false

        // Collection behavior for Spaces/Mission Control
        collectionBehavior = [
            .canJoinAllSpaces,      // Show on all desktops/spaces
            .stationary,            // Don't move with Mission Control
            .ignoresCycle           // Don't appear in Cmd+Tab or window cycling
        ]

        // Prevent window from being closed or released
        isReleasedWhenClosed = false

        // Make sure window spans the entire screen
        if let screen = screen {
            setFrame(screen.frame, display: true)
        }
    }

    /// Update window frame when screen configuration changes
    func updateFrame(for screen: NSScreen) {
        setFrame(screen.frame, display: true)
    }

    // Prevent window from becoming key or main
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
