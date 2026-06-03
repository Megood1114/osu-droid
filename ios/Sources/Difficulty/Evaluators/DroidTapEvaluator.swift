import Foundation

public final class DroidTapEvaluator {
    private static let MIN_SPEED_BONUS = 75.0

    public static func evaluateDifficultyOf(
        current: DroidDifficultyHitObject,
        considerCheesability: Bool,
        strainTimeCap: Double? = nil
    ) -> Double {
        if current.obj is Spinner || current.isOverlapping(false) {
            return 0.0
        }

        let doubletapness = considerCheesability ? (1.0 - current.getDoubletapness(current.next(0))) : 1.0

        var strainTime = current.strainTime
        if let cap = strainTimeCap {
            strainTime = max(50.0, max(cap, strainTime))
        }

        var speedBonus = 1.0
        if current.strainTime < MIN_SPEED_BONUS {
            speedBonus += 0.75 * pow(ErrorFunction.erfFast((MIN_SPEED_BONUS - strainTime) / 40.0), 2.0)
        }

        return speedBonus * pow(doubletapness, 1.5) * 1000.0 / strainTime
    }
}
