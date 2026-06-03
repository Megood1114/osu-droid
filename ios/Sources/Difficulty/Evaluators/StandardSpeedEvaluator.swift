import Foundation

public final class StandardSpeedEvaluator {
    private static let SINGLE_SPACING_THRESHOLD = Double(DifficultyHitObject.normalizedDiameter) * 1.25
    private static let MIN_SPEED_BONUS = 75.0
    private static let DISTANCE_MULTIPLIER = 0.8

    public static func evaluateDifficultyOf(current: StandardDifficultyHitObject, mods: [Mod]) -> Double {
        if current.obj is Spinner {
            return 0.0
        }

        let prev = current.previous(0)
        var strainTime = current.strainTime

        let doubletapness = 1.0 - current.getDoubletapness(nextObj: current.next(0))

        strainTime /= min(1.0, max(0.92, strainTime / current.fullGreatWindow / 0.93))

        var speedBonus = 0.0
        if strainTime < MIN_SPEED_BONUS {
            speedBonus = 0.75 * pow((MIN_SPEED_BONUS - strainTime) / 40.0, 2.0)
        }

        let travelDistance = prev?.travelDistance ?? 0.0
        let distance = min(SINGLE_SPACING_THRESHOLD, travelDistance + current.minimumJumpDistance)

        var distanceBonus = 0.0
        if !mods.contains(where: { $0 is ModAutopilot }) {
            distanceBonus = pow(distance / SINGLE_SPACING_THRESHOLD, 3.95) * DISTANCE_MULTIPLIER
        }

        distanceBonus *= sqrt(current.smallCircleBonus)

        let difficulty = (1.0 + speedBonus + distanceBonus) * 1000.0 / strainTime
        return difficulty * doubletapness
    }
}
