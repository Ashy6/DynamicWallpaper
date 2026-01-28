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
├── DynamicWallpaperApp.swift    # App entry point with MenuBarExtra
├── Views/
│   └── MenuBarView.swift        # Menu bar control interface
├── Wallpaper/
│   ├── WallpaperWindow.swift    # Desktop-level window
│   ├── VideoPlayerView.swift    # Video player using AVFoundation
│   └── WallpaperManager.swift   # Core manager for wallpaper state
├── Info.plist                   # App configuration
└── DynamicWallpaper.entitlements # App Sandbox permissions
```

## Technical Details

- Uses `CGWindowLevelForKey(.desktopWindow)` to place video window at desktop level
- Uses `AVPlayer` with `AVPlayerLooper` for seamless video looping
- SwiftUI `MenuBarExtra` for menu bar interface
- Supports multiple displays via `NSScreen.screens`

## License

MIT License
