import SwiftUI
import UniformTypeIdentifiers

/// Menu bar popover view with wallpaper controls
struct MenuBarView: View {
    @ObservedObject var wallpaperManager = WallpaperManager.shared

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "play.display")
                    .font(.title2)
                Text("Dynamic Wallpaper")
                    .font(.headline)
            }
            .padding(.bottom, 4)

            Divider()

            // Current video info
            if let url = wallpaperManager.currentVideoURL {
                HStack {
                    Image(systemName: "film")
                        .foregroundColor(.secondary)
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            } else {
                Text("No video selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Playback controls
            HStack(spacing: 20) {
                // Play/Pause button
                Button {
                    wallpaperManager.togglePlayPause()
                } label: {
                    Image(systemName: wallpaperManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .help(wallpaperManager.isPlaying ? "Pause" : "Play")
                .disabled(!wallpaperManager.isActive)
                .opacity(wallpaperManager.isActive ? 1.0 : 0.5)

                // Mute button
                Button {
                    wallpaperManager.toggleMute()
                } label: {
                    Image(systemName: wallpaperManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.title)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .help(wallpaperManager.isMuted ? "Unmute" : "Mute")
                .disabled(!wallpaperManager.isActive)
                .opacity(wallpaperManager.isActive ? 1.0 : 0.5)
            }
            .padding(.vertical, 8)

            // Volume slider
            if wallpaperManager.isActive {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.secondary)
                    Slider(value: $wallpaperManager.volume, in: 0...1)
                        .frame(width: 140)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }

            Divider()

            // Select video button
            Button {
                selectVideoFile()
            } label: {
                HStack {
                    Image(systemName: "folder")
                    Text("Select Video...")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            // Stop button (only shown when active)
            if wallpaperManager.isActive {
                Button(role: .destructive) {
                    wallpaperManager.stop()
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop Wallpaper")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Quit button
            Button {
                wallpaperManager.stop()
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 220)
    }

    /// Open file picker for video selection
    private func selectVideoFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            UTType.movie,
            UTType.video,
            UTType.mpeg4Movie,
            UTType.quickTimeMovie
        ]
        panel.message = "Select a video file for wallpaper"
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            wallpaperManager.setVideo(url: url)
        }
    }
}

#Preview {
    MenuBarView()
}
