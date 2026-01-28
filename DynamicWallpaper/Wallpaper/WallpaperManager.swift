import AppKit
import Combine

/// Manages wallpaper windows and video playback across all screens
class WallpaperManager: ObservableObject {

    /// Shared singleton instance
    static let shared = WallpaperManager()

    /// Current video URL being displayed
    @Published var currentVideoURL: URL?

    /// Whether video is playing
    @Published var isPlaying: Bool = true

    /// Whether audio is muted
    @Published var isMuted: Bool = true

    /// Volume level (0.0 to 1.0)
    @Published var volume: Float = 0.5

    /// Whether wallpaper is currently active
    @Published var isActive: Bool = false

    /// Wallpaper windows for each screen
    private var wallpaperWindows: [String: WallpaperWindow] = [:]

    /// Video views for each screen
    private var videoViews: [String: VideoPlayerView] = [:]

    /// Screen configuration observer
    private var screenObserver: NSObjectProtocol?

    /// Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupScreenObserver()
        setupBindings()
    }

    // MARK: - Setup

    private func setupScreenObserver() {
        // Listen for screen configuration changes
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenChange()
        }
    }

    private func setupBindings() {
        // Sync playing state to all video views
        $isPlaying
            .sink { [weak self] playing in
                self?.videoViews.values.forEach { $0.isPlaying = playing }
            }
            .store(in: &cancellables)

        // Sync muted state to all video views
        $isMuted
            .sink { [weak self] muted in
                self?.videoViews.values.forEach { $0.isMuted = muted }
            }
            .store(in: &cancellables)

        // Sync volume to all video views
        $volume
            .sink { [weak self] vol in
                self?.videoViews.values.forEach { $0.volume = vol }
            }
            .store(in: &cancellables)
    }

    // MARK: - Screen Management

    private func createWindowsForAllScreens() {
        for screen in NSScreen.screens {
            let screenID = screenIdentifier(for: screen)

            if wallpaperWindows[screenID] == nil {
                let window = WallpaperWindow(for: screen)
                wallpaperWindows[screenID] = window
            }
        }
    }

    private func handleScreenChange() {
        let currentScreenIDs = Set(NSScreen.screens.map { screenIdentifier(for: $0) })

        // Remove windows for disconnected screens
        for screenID in wallpaperWindows.keys {
            if !currentScreenIDs.contains(screenID) {
                wallpaperWindows[screenID]?.close()
                wallpaperWindows.removeValue(forKey: screenID)
                videoViews[screenID]?.cleanup()
                videoViews.removeValue(forKey: screenID)
            }
        }

        // Create windows for new screens and update existing ones
        for screen in NSScreen.screens {
            let screenID = screenIdentifier(for: screen)

            if let window = wallpaperWindows[screenID] {
                window.updateFrame(for: screen)
                videoViews[screenID]?.frame = screen.frame
            } else {
                // New screen detected
                let window = WallpaperWindow(for: screen)
                wallpaperWindows[screenID] = window

                // Set up video if we have one
                if let url = currentVideoURL {
                    setupVideoView(for: screenID, screen: screen, url: url, window: window)
                }

                if isActive {
                    window.orderFront(nil)
                }
            }
        }
    }

    private func screenIdentifier(for screen: NSScreen) -> String {
        // Use screen's device description to create unique identifier
        if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
            return "screen-\(screenNumber)"
        }
        return "screen-\(screen.hash)"
    }

    // MARK: - Video Management

    private func setupVideoView(for screenID: String, screen: NSScreen, url: URL, window: WallpaperWindow) {
        let videoView = VideoPlayerView(frame: screen.frame)
        videoView.videoURL = url
        videoView.isPlaying = isPlaying
        videoView.isMuted = isMuted
        videoView.volume = volume

        window.contentView = videoView
        videoViews[screenID] = videoView
    }

    // MARK: - Public Methods

    /// Set a video as the wallpaper
    func setVideo(url: URL) {
        currentVideoURL = url

        // Create windows if needed
        createWindowsForAllScreens()

        // Set up video views for all screens
        for screen in NSScreen.screens {
            let screenID = screenIdentifier(for: screen)

            if let window = wallpaperWindows[screenID] {
                // Clean up existing video view
                videoViews[screenID]?.cleanup()

                setupVideoView(for: screenID, screen: screen, url: url, window: window)
            }
        }

        isActive = true
        showWallpapers()
    }

    /// Show all wallpaper windows
    func showWallpapers() {
        wallpaperWindows.values.forEach { window in
            window.orderFront(nil)
        }
    }

    /// Hide all wallpaper windows
    func hideWallpapers() {
        wallpaperWindows.values.forEach { window in
            window.orderOut(nil)
        }
    }

    /// Toggle play/pause state
    func togglePlayPause() {
        isPlaying.toggle()
    }

    /// Toggle mute state
    func toggleMute() {
        isMuted.toggle()
    }

    /// Stop wallpaper and clean up
    func stop() {
        hideWallpapers()

        // Clean up video views
        videoViews.values.forEach { $0.cleanup() }
        videoViews.removeAll()

        currentVideoURL = nil
        isActive = false
    }

    deinit {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        stop()
    }
}
