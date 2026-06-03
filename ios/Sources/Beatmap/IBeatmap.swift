import Foundation

/// Represents a beatmap.
protocol IBeatmap {
    /// The format version of this `IBeatmap`.
    var formatVersion: Int { get }

    /// The general section of this `IBeatmap`.
    var general: BeatmapGeneral { get }

    /// The metadata section of this `IBeatmap`.
    var metadata: BeatmapMetadata { get }

    /// The difficulty section of this `IBeatmap`.
    var difficulty: BeatmapDifficulty { get }

    /// The events section of this `IBeatmap`.
    var events: BeatmapEvents { get }

    /// The colors section of this `IBeatmap`.
    var colors: BeatmapColor { get }

    /// The control points of this `IBeatmap`.
    var controlPoints: BeatmapControlPoints { get }

    /// The hit objects of this `IBeatmap`.
    var hitObjects: BeatmapHitObjects { get }

    /// The path to the `.osu` file of this `IBeatmap`.
    var filePath: String { get }

    /// The path of the parent folder of this `IBeatmap`.
    ///
    /// In other words, this is the beatmapset folder of this `IBeatmap`.
    var beatmapsetPath: String { get }

    /// The MD5 hash of this `IBeatmap`.
    var md5: String { get }

    /// The maximum combo of this `IBeatmap`.
    var maxCombo: Int { get }

    /// The duration of this `IBeatmap`.
    var duration: Int { get }

    /// Returns a time combined with beatmap-wide time offset.
    ///
    /// Beatmap version 4 and lower had an incorrect offset. Stable has this set as 24ms off.
    ///
    /// - Parameter time: The time.
    func getOffsetTime(time: Double) -> Double

    /// Returns a time combined with beatmap-wide time offset.
    ///
    /// Beatmap version 4 and lower had an incorrect offset. Stable has this set as 24ms off.
    ///
    /// - Parameter time: The time.
    func getOffsetTime(time: Int) -> Int
}

extension IBeatmap {
    var beatmapsetPath: String {
        guard let lastSlashIndex = filePath.lastIndex(of: "/") else { return filePath }
        return String(filePath[..<lastSlashIndex])
    }

    var duration: Int {
        if let lastObj = hitObjects.objects.last {
            return Int(lastObj.endTime)
        }
        return 0
    }

    func getOffsetTime(time: Double) -> Double {
        return time + (formatVersion < 5 ? 24.0 : 0.0)
    }

    func getOffsetTime(time: Int) -> Int {
        return time + (formatVersion < 5 ? 24 : 0)
    }
}
