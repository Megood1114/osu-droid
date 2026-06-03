import Foundation

/// Represents a HitObject with additional information for osu!standard difficulty calculation.
public class StandardDifficultyHitObject: DifficultyHitObject {
    public override var mode: GameMode {
        return .standard
    }

    public override var smallCircleBonus: Double {
        return max(1.0, 1.0 + Double(30.0 - obj.difficultyRadius) / 40.0)
    }

    public init(
        obj: HitObject,
        lastObj: HitObject,
        clockRate: Double,
        difficultyHitObjects: [StandardDifficultyHitObject],
        index: Int
    ) {
        super.init(
            obj: obj,
            lastObj: lastObj,
            clockRate: clockRate,
            difficultyHitObjects: difficultyHitObjects,
            index: index
        )
    }
}
