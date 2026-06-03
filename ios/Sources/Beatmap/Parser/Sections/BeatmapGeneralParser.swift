import Foundation

/// A parser for parsing a beatmap's general section.
class BeatmapGeneralParser: BeatmapKeyValueSectionParser {
    override func parse(beatmap: Beatmap, line: String) throws {
        guard let property = splitProperty(line: line) else {
            throw NSError(domain: "BeatmapGeneralParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed general property: \(line)"])
        }
        
        switch property.0 {
        case "AudioFilename":
            beatmap.general.audioFilename = property.1
        case "AudioLeadIn":
            beatmap.general.audioLeadIn = try parseInt(property.1)
        case "PreviewTime":
            beatmap.general.previewTime = beatmap.getOffsetTime(time: try parseInt(property.1))
        case "Countdown":
            beatmap.general.countdown = BeatmapCountdown(rawValue: property.1) ?? .none // Adjust based on BeatmapCountdown translation
        case "SampleSet":
            beatmap.general.sampleBank = SampleBank.parse(property.1)
        case "SampleVolume":
            beatmap.general.sampleVolume = try parseInt(property.1)
        case "StackLeniency":
            beatmap.general.stackLeniency = try parseFloat(property.1)
        case "LetterboxInBreaks":
            beatmap.general.letterboxInBreaks = (property.1 == "1")
        case "EpilepsyWarning":
            beatmap.general.epilepsyWarning = (property.1 == "1")
        case "Mode":
            beatmap.general.mode = try parseInt(property.1)
        case "SamplesMatchPlaybackRate":
            beatmap.general.samplesMatchPlaybackRate = (property.1 == "1")
        default:
            break
        }
    }
}
