import Foundation

// MARK: - ModType

public enum ModType: String {
    case difficultyReduction = "Difficulty Reduction"
    case difficultyIncrease = "Difficulty Increase"
    case automation = "Automation"
    case conversion = "Conversion"
    case fun = "Fun"
    case system = "System"
}

// MARK: - APIMod

public struct APIMod: Codable {
    public let acronym: String
    
    // We assume settings can be represented as a JSON dictionary if needed.
    // In a real scenario, this might need a custom Decodable to handle any values.
    public let settings: [String: String]? 
    
    public init(acronym: String, settings: [String: String]? = nil) {
        self.acronym = acronym
        self.settings = settings
    }
}

// MARK: - Interfaces

protocol IMigratableMod {
    func migrate(difficulty: BeatmapDifficulty) -> Mod
}

protocol IModApplicableToBeatmap {
    func applyToBeatmap(_ beatmap: Beatmap)
}

protocol IModApplicableToDifficulty {
    func applyToDifficulty(mode: GameMode, difficulty: BeatmapDifficulty, adjustmentMods: [IModFacilitatesAdjustment])
}

protocol IModApplicableToDifficultyWithMods {
    func applyToDifficulty(mode: GameMode, difficulty: BeatmapDifficulty, mods: [Mod])
}

protocol IModApplicableToHitObject {
    func applyToHitObject(mode: GameMode, hitObject: HitObject, adjustmentMods: [IModFacilitatesAdjustment])
}

protocol IModApplicableToHitObjectWithMods {
    func applyToHitObject(mode: GameMode, hitObject: HitObject, mods: [Mod])
}

protocol IModApplicableToTrackRate {
    func applyToRate(time: Double, rate: Float) -> Float
}

public extension IModApplicableToTrackRate {
    func applyToRate(time: Double, rate: Float = 1.0) -> Float {
        return applyToRate(time: time, rate: rate)
    }
}

protocol IModFacilitatesAdjustment {}

protocol IModRequiresBeatmapDifficulty {
    func applyFromBeatmapDifficulty(difficulty: BeatmapDifficulty)
}
