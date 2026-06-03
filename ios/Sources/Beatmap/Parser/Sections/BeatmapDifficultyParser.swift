import Foundation

/// A parser for parsing a beatmap's difficulty section.
class BeatmapDifficultyParser: BeatmapKeyValueSectionParser {
    override func parse(beatmap: Beatmap, line: String) throws {
        guard let property = splitProperty(line: line) else {
            throw NSError(domain: "BeatmapDifficultyParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed difficulty property: \(line)"])
        }
        
        switch property.0 {
        case "CircleSize":
            let value = try parseFloat(property.1)
            beatmap.difficulty.difficultyCS = value
            beatmap.difficulty.gameplayCS = value
        case "OverallDifficulty":
            beatmap.difficulty.od = try parseFloat(property.1)
        case "ApproachRate":
            beatmap.difficulty.ar = try parseFloat(property.1)
        case "HPDrainRate":
            beatmap.difficulty.hp = try parseFloat(property.1)
        case "SliderMultiplier":
            beatmap.difficulty.sliderMultiplier = min(max(try parseDouble(property.1), 0.4), 3.6)
        case "SliderTickRate":
            beatmap.difficulty.sliderTickRate = min(max(try parseDouble(property.1), 0.5), 8.0)
        default:
            break
        }
    }
}
