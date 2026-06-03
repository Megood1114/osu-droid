import Foundation

/// Contains general information about a beatmap.
public struct BeatmapGeneral {
    /// The location of the audio file relative to the beatmapset file.
    public var audioFilename: String = ""

    /// The amount of milliseconds of silence before the audio starts playing.
    public var audioLeadIn: Int = 0

    /// The time in milliseconds when the audio preview should start.
    ///
    /// If -1, the audio should begin playing at 40% of its length.
    public var previewTime: Int = -1

    /// The speed of the countdown before the first hit object.
    var countdown: BeatmapCountdown = .normal

    /// The sample bank that will be used if timing points do not override it.
    var sampleBank: SampleBank = .normal

    /// The sample volume that will be used if timing points do not override it.
    public var sampleVolume: Int = 100

    /// The multiplier for the threshold in time where hit objects
    /// placed close together stack, ranging from 0 to 1.
    public var stackLeniency: Float = 0.7

    /// Whether breaks have a letterboxing effect.
    public var letterboxInBreaks: Bool = false

    /// The game mode this beatmap represents.
    public var mode: Int = 0

    /// Whether sound samples will change rate when playing with rate-adjusting mods.
    public var samplesMatchPlaybackRate: Bool = false

    /// Whether a warning about flashing colours should be shown at the beginning of the beatmap.
    public var epilepsyWarning: Bool = false
    
    public init() {}
}
