# Dynamic Wallpaper

A macOS menu bar application that allows you to set MP4 videos as your desktop wallpaper.

## Features

- Play MP4 videos as desktop wallpaper
- Video displays below all windows and desktop icons
- Play/Pause control
- Mute/Unmute control
- Volume slider
- Multi-monitor support
- Seamless video looping
- Menu bar app (no Dock icon)

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

## Installation

1. Open `DynamicWallpaper.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run (Cmd + R)

## Usage

1. Click the display icon in the menu bar
2. Click "Select Video..." to choose an MP4 file
3. The video will start playing as your desktop wallpaper
4. Use the play/pause and mute buttons to control playback
5. Adjust volume using the slider
6. Click "Stop Wallpaper" to return to normal desktop
7. Click "Quit" to exit the application

## Project Structure

```
DynamicWallpaper/
├── DynamicWallpaper.xcodeproj/
│   └── project.pbxproj
├── DynamicWallpaper/
│   ├── DynamicWallpaperApp.swift       # App entry point + MenuBarExtra
│   ├── Views/
│   │   └── MenuBarView.swift           # Menu bar control interface (with volume slider)
│   ├── Wallpaper/
│   │   ├── WallpaperWindow.swift       # Desktop-level window
│   │   ├── VideoPlayerView.swift       # Video player view
│   │   └── WallpaperManager.swift      # Core manager
│   ├── Managers/
│   │   ├── FullscreenDetector.swift    # Fullscreen app detection
│   │   └── LaunchAtLogin.swift         # Launch at login management
│   ├── Storage/
│   │   └── SettingsStorage.swift       # Persistence + Bookmark
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/
│   ├── Info.plist                      # LSUIElement=true (no Dock icon)
│   └── DynamicWallpaper.entitlements   # App Sandbox permissions
├── README.md
└── .gitignore
```

## Implementation Steps

### 1. Create Xcode Project
- Create new macOS App project
- Interface: SwiftUI
- Deployment Target: macOS 13.0+

### 2. Implement Desktop-Level Window (WallpaperWindow.swift)
- Inherit from `NSWindow`
- Set `level = CGWindowLevelForKey(.desktopWindow)`
- Configure `borderless` style, ignore mouse events
- Set `collectionBehavior` to show on all desktop spaces

### 3. Implement Video Playback (VideoPlayerView.swift)
- Use `AVPlayer` + `AVPlayerLayer`
- Use `AVPlayerLooper` for seamless looping
- Support play/pause, mute controls
- Video fill mode: `resizeAspectFill`

### 4. Implement Wallpaper Manager (WallpaperManager.swift)
- Manage multi-screen window creation
- Listen for screen configuration changes
- Coordinate all video player states
- Use Combine for reactive updates

### 5. Implement Menu Bar Interface (MenuBarView.swift)
- Play/Pause button
- Mute/Unmute button
- Select video file button
- Stop wallpaper button
- Quit application button

### 6. Configure App Entry Point (DynamicWallpaperApp.swift)
- Use `MenuBarExtra` as main entry
- Configure as Agent mode (no Dock icon)

### 7. Configure Permissions
- Info.plist: `LSUIElement = true`
- Entitlements: App Sandbox + file read permissions

### 8. Implement Launch at Login (LaunchAtLogin.swift)
- Use `SMAppService` (macOS 13+) or `ServiceManagement`
- Provide toggle in settings

### 9. Implement Persistent Storage (SettingsStorage.swift)
- Use `UserDefaults` for settings storage
- Use `Security Scoped Bookmark` for persistent video file access
- Auto-restore last played video on app launch

### 10. Implement Volume Slider (MenuBarView.swift)
- SwiftUI `Slider` control
- Bind to `WallpaperManager.volume`

### 11. Implement Fullscreen Detection (FullscreenDetector.swift)
- Listen for `NSWorkspace.activeSpaceDidChangeNotification`
- Use `CGWindowListCopyWindowInfo` to detect fullscreen apps
- Pause video when fullscreen, resume when exiting fullscreen

## Verification Checklist

1. Run app, confirm menu bar icon appears
2. Click "Select Video" to choose an MP4 file
3. Confirm video plays at desktop level (below all windows)
4. Test play/pause button
5. Test mute/unmute button
6. Test volume slider adjustment
7. Test stop wallpaper function
8. Test multi-monitor support (if available)
9. Open fullscreen app (e.g., video player), confirm wallpaper auto-pauses
10. Exit fullscreen, confirm wallpaper resumes playback
11. Restart app, confirm last played video auto-restores
12. Test launch at login toggle

## Key Files

| File | Description |
|------|-------------|
| `DynamicWallpaper/DynamicWallpaperApp.swift` | App entry point |
| `DynamicWallpaper/Views/MenuBarView.swift` | Menu bar interface (with volume slider) |
| `DynamicWallpaper/Wallpaper/WallpaperWindow.swift` | Desktop-level window |
| `DynamicWallpaper/Wallpaper/VideoPlayerView.swift` | Video player |
| `DynamicWallpaper/Wallpaper/WallpaperManager.swift` | Core manager |
| `DynamicWallpaper/Managers/FullscreenDetector.swift` | Fullscreen detection |
| `DynamicWallpaper/Managers/LaunchAtLogin.swift` | Launch at login |
| `DynamicWallpaper/Storage/SettingsStorage.swift` | Persistent storage |
| `DynamicWallpaper/Info.plist` | App configuration |
| `DynamicWallpaper/DynamicWallpaper.entitlements` | Permission configuration |

## Technical Details

- Uses `CGWindowLevelForKey(.desktopWindow)` to place video window at desktop level
- Uses `AVPlayer` with `AVPlayerLooper` for seamless video looping
- SwiftUI `MenuBarExtra` for menu bar interface
- Supports multiple displays via `NSScreen.screens`

## License

MIT License
