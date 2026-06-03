import Foundation

/// Handles importing .osz beatmap archives into the app's Songs directory.
class BeatmapImporter {

    static let shared = BeatmapImporter()
    private init() {}

    /// Import a .osz beatmap archive from a URL.
    /// Extracts the archive contents into the Songs directory.
    func importBeatmapArchive(at url: URL) {
        let songsDir = AppConfig.beatmapPath

        // Ensure access to the file
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let beatmapName = url.deletingPathExtension().lastPathComponent
        let destinationDir = songsDir.appendingPathComponent(beatmapName)

        do {
            let fm = FileManager.default

            // Create destination directory
            if !fm.fileExists(atPath: destinationDir.path) {
                try fm.createDirectory(at: destinationDir, withIntermediateDirectories: true)
            }

            // Copy file to temp location for extraction
            let tempURL = AppConfig.cachePath.appendingPathComponent(url.lastPathComponent)
            if fm.fileExists(atPath: tempURL.path) {
                try fm.removeItem(at: tempURL)
            }
            try fm.copyItem(at: url, to: tempURL)

            // TODO: Extract ZIP contents (osz is a renamed zip)
            // Will use ZIPFoundation or similar library
            print("[BeatmapImporter] Copied \(beatmapName) to Songs directory")
            print("[BeatmapImporter] ZIP extraction not yet implemented — needs ZIPFoundation")

            // Clean up temp file
            try? fm.removeItem(at: tempURL)

        } catch {
            print("[BeatmapImporter] Failed to import beatmap: \(error)")
        }
    }
}
