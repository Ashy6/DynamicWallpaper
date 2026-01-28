import SwiftUI

@main
struct DynamicWallpaperApp: App {
    @StateObject private var wallpaperManager = WallpaperManager.shared

    var body: some Scene {
        // Menu bar application with popover window style
        MenuBarExtra {
            MenuBarView()
        } label: {
            // Menu bar icon changes based on active state
            Image(systemName: wallpaperManager.isActive ? "play.display" : "display")
        }
        .menuBarExtraStyle(.window)
    }
}
