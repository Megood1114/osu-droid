import Foundation

/// Contains beatmap events.
public class BeatmapEvents {
    /// The file name of this beatmap's background.
    public var backgroundFilename: String? = nil

    /// The file name of this beatmap's background video.
    public var videoFilename: String? = nil

    /// The beatmap's background video start time in milliseconds.
    public var videoStartTime: Int = 0

    /// The breaks this beatmap has.
    var breaks: [BreakPeriod] = []

    /// The background color of this beatmap.
    var backgroundColor: Color4? = nil
    
    public init() {}
}
