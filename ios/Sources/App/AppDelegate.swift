import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Application-wide configuration loaded at startup.
    static var gameConfig = AppConfig()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize file system directories
        AppConfig.initializeDirectories()
        AppConfig.setupLogger()

        // Configure audio session for low-latency playback
        configureAudioSession()

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        // BASS manages its own audio session on iOS.
        // We just need to ensure the category is set for playback.
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            // Initialize BASS Audio Engine
            if BASS_Init(-1, 44100, 0, nil, nil) == 0 {
                let error = BASS_ErrorGetCode()
                if error != BASS_ERROR_ALREADY {
                    print("[osu!droid] Failed to initialize BASS. Error code: \(error)")
                }
            } else {
                print("[osu!droid] BASS initialized successfully.")
            }
        } catch {
            print("[osu!droid] Failed to configure audio session: \(error)")
        }
    }

    // MARK: - File Import Handling

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return handleFileImport(url: url)
    }

    private func handleFileImport(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "osz":
            // Import beatmap archive
            BeatmapImporter.shared.importBeatmapArchive(at: url)
            return true
        case "osk":
            // Import skin archive (future)
            print("[osu!droid] Skin import not yet implemented")
            return true
        case "odr":
            // Import replay (future)
            print("[osu!droid] Replay import not yet implemented")
            return true
        default:
            return false
        }
    }
}

import AVFoundation
