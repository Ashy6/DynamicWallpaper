import AppKit
import AVFoundation

/// NSView subclass that displays a looping video using AVPlayer
class VideoPlayerView: NSView {

    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?

    /// The video URL to play
    var videoURL: URL? {
        didSet {
            if videoURL != oldValue {
                setupPlayer()
            }
        }
    }

    /// Whether the video is currently playing
    var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                player?.play()
            } else {
                player?.pause()
            }
        }
    }

    /// Whether the audio is muted
    var isMuted: Bool = true {
        didSet {
            player?.isMuted = isMuted
        }
    }

    /// Volume level (0.0 to 1.0)
    var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
    }

    private func setupPlayer() {
        // Clean up existing player
        cleanup()

        guard let url = videoURL else { return }

        // Create player item and queue player
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        // Use AVQueuePlayer with AVPlayerLooper for seamless looping
        let queuePlayer = AVQueuePlayer()
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer

        // Create and configure player layer
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill  // Fill entire screen
        layer.frame = bounds
        playerLayer = layer

        // Remove old sublayers and add new one
        self.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.layer?.addSublayer(layer)

        // Apply current settings
        player?.isMuted = isMuted
        player?.volume = volume

        // Start playback if needed
        if isPlaying {
            player?.play()
        }
    }

    override func layout() {
        super.layout()
        playerLayer?.frame = bounds
    }

    /// Clean up player resources
    func cleanup() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    deinit {
        cleanup()
    }
}
