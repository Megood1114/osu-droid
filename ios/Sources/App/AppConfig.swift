import Foundation
import UIKit

/// Application-wide configuration.
/// Port of Config.java — maps SharedPreferences to UserDefaults.
struct AppConfig {

    // MARK: - Directory Paths

    /// Root directory for all osu!droid data (Documents/osu!droid/)
    static var corePath: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("osu!droid")
    }

    /// Directory where beatmaps are stored
    static var beatmapPath: URL {
        return corePath.appendingPathComponent("Songs")
    }

    /// Directory for cached data
    static var cachePath: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("osu!droid")
    }

    /// Directory for skin files
    static var skinPath: URL {
        return corePath.appendingPathComponent("Skin")
    }

    /// Directory for score/replay files
    static var scorePath: URL {
        return corePath.appendingPathComponent("Scores")
    }

    /// Directory for exported replays
    static var replayPath: URL {
        return corePath.appendingPathComponent("Replays")
    }

    // MARK: - Screen Configuration

    /// The current screen scale factor
    static var screenScale: CGFloat {
        return UIScreen.main.scale
    }

    /// Render resolution width
    static var renderWidth: CGFloat = 1920

    /// Render resolution height
    static var renderHeight: CGFloat = 1080

    // MARK: - Gameplay Settings (UserDefaults)

    private static let defaults = UserDefaults.standard

    /// Background dim level (0.0 to 1.0)
    static var backgroundBrightness: Float {
        get { defaults.float(forKey: "backgroundBrightness", defaultValue: 0.25) }
        set { defaults.set(newValue, forKey: "backgroundBrightness") }
    }
    
    /// Background music volume (0.0 to 1.0)
    static var bgmVolume: Float {
        get { defaults.float(forKey: "bgmVolume", defaultValue: 1.0) }
        set { defaults.set(newValue, forKey: "bgmVolume") }
    }

    /// Sound effects volume (0.0 to 1.0)
    static var soundVolume: Float {
        get { defaults.float(forKey: "soundVolume", defaultValue: 1.0) }
        set { defaults.set(newValue, forKey: "soundVolume") }
    }

    /// Whether to show the first approach circle
    static var showFirstApproachCircle: Bool {
        get { defaults.bool(forKey: "showFirstApproachCircle", defaultValue: true) }
        set { defaults.set(newValue, forKey: "showFirstApproachCircle") }
    }

    /// Whether combo bursts are enabled
    static var comboBurstEnabled: Bool {
        get { defaults.bool(forKey: "comboburst", defaultValue: false) }
        set { defaults.set(newValue, forKey: "comboburst") }
    }

    /// Whether to use custom skins
    static var useCustomSkins: Bool {
        get { defaults.bool(forKey: "useCustomSkins", defaultValue: false) }
        set { defaults.set(newValue, forKey: "useCustomSkins") }
    }

    /// Audio offset in milliseconds
    static var offset: Int {
        get { defaults.integer(forKey: "offset", defaultValue: 0) }
        set { defaults.set(newValue, forKey: "offset") }
    }

    /// Whether to play hit sounds
    static var playHitSounds: Bool {
        get { defaults.bool(forKey: "hitSound", defaultValue: true) }
        set { defaults.set(newValue, forKey: "hitSound") }
    }

    /// Whether to enable haptic feedback on hit
    static var hapticFeedback: Bool {
        get { defaults.bool(forKey: "hapticFeedback", defaultValue: true) }
        set { defaults.set(newValue, forKey: "hapticFeedback") }
    }

    /// Cursor scale
    static var cursorSize: Float {
        get { defaults.float(forKey: "cursorSize", defaultValue: 1.0) }
        set { defaults.set(newValue, forKey: "cursorSize") }
    }

    /// Whether to force max display refresh rate
    static var forceMaxRefreshRate: Bool {
        get { defaults.bool(forKey: "forceMaxRefreshRate", defaultValue: true) }
        set { defaults.set(newValue, forKey: "forceMaxRefreshRate") }
    }

    /// Whether to keep background aspect ratio
    static var keepBackgroundAspectRatio: Bool {
        get { defaults.bool(forKey: "keepBackgroundAspectRatio", defaultValue: true) }
        set { defaults.set(newValue, forKey: "keepBackgroundAspectRatio") }
    }

    // MARK: - Initialization

    /// Create all required directories on first launch.
    static func initializeDirectories() {
        let fm = FileManager.default
        let dirs = [corePath, beatmapPath, cachePath, skinPath, scorePath, replayPath]

        for dir in dirs {
            if !fm.fileExists(atPath: dir.path) {
                do {
                    try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                    print("[Config] Created directory: \(dir.lastPathComponent)")
                } catch {
                    print("[Config] Failed to create directory \(dir.lastPathComponent): \(error)")
                }
            }
        }
    }

    /// Setup file logging so stdout and stderr are written to the Documents directory.
    static func setupLogger() {
        let logFileURL = corePath.appendingPathComponent("latest.log")
        
        // Ensure core path exists
        try? FileManager.default.createDirectory(at: corePath, withIntermediateDirectories: true)
        
        // Redirect stdout and stderr
        freopen(logFileURL.path.cString(using: .utf8), "w", stdout)
        freopen(logFileURL.path.cString(using: .utf8), "w", stderr)
        
        // Disable buffering to ensure hard crashes are written immediately
        setvbuf(stdout, nil, _IONBF, 0)
        setvbuf(stderr, nil, _IONBF, 0)
        
        print("==========================================")
        print("[Logger] osu!droid iOS Log Started")
        print("[Logger] Date: \\(Date())")
        print("==========================================")
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {

    func float(forKey key: String, defaultValue: Float) -> Float {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return float(forKey: key)
    }

    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return integer(forKey: key)
    }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}
