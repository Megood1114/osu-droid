import Foundation

/// Contains information used to identify a beatmap.
public struct BeatmapMetadata {
    /// The romanized song title of this beatmap.
    public var title: String = ""

    /// The song title of this beatmap.
    public var titleUnicode: String = ""

    /// The romanized artist of the song of this beatmap.
    public var artist: String = ""

    /// The song artist of this beatmap.
    public var artistUnicode: String = ""

    /// The creator of this beatmap.
    public var creator: String = ""

    /// The difficulty name of this beatmap.
    public var version: String = ""

    /// The original media the song was produced for.
    public var source: String = ""

    /// The search terms of this beatmap.
    public var tags: String = ""

    /// The ID of this beatmap.
    public var beatmapId: Int = -1

    /// The ID of this beatmap set containing this beatmap.
    public var beatmapSetId: Int = -1
    
    public init() {}
}
