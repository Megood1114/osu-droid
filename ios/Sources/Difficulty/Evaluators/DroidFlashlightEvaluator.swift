import Foundation

public final class DroidFlashlightEvaluator {
    private static let MAX_OPACITY_BONUS = 0.4
    private static let HIDDEN_BONUS = 0.2
    private static let TRACEABLE_CIRCLE_BONUS = 0.15
    private static let TRACEABLE_OBJECT_BONUS = 0.1
    private static let MIN_VELOCITY = 0.5
    private static let SLIDER_MULTIPLIER = 1.3
    private static let MIN_ANGLE_MULTIPLIER = 0.2

    public static func evaluateDifficultyOf(current: DroidDifficultyHitObject, mods: [Mod], withSliders: Bool) -> Double {
        if current.obj is Spinner || current.isOverlapping(true) {
            return 0.0
        }

        let scalingFactor = 52.0 / current.obj.difficultyRadius
        var smallDistNerf = 1.0
        var cumulativeStrainTime = 0.0
        var result = 0.0
        var last = current
        var angleRepeatCount = 0.0

        for i in 0..<min(current.index, 10) {
            let currentObject = current.previous(i)! as! DroidDifficultyHitObject
            cumulativeStrainTime += last.strainTime

            if !(currentObject.obj is Spinner) {
                let jumpDistance = current.obj.difficultyStackedPosition.getDistance(currentObject.obj.difficultyStackedEndPosition)

                if i == 0 {
                    smallDistNerf = min(1.0, jumpDistance / 75.0)
                }

                let stackNerf = min(1.0, currentObject.lazyJumpDistance / scalingFactor / 25.0)
                let opacityBonus = 1.0 + MAX_OPACITY_BONUS * (1.0 - current.opacityAt(currentObject.obj.startTime, mods))
                
                result += stackNerf * opacityBonus * scalingFactor * jumpDistance / cumulativeStrainTime

                if let currentObjectAngle = currentObject.angle, let currentAngle = current.angle, abs(currentObjectAngle - currentAngle) < 0.02 {
                    angleRepeatCount += max(0.0, 1.0 - 0.1 * Double(i))
                }
            }
            last = currentObject
        }

        result = pow(smallDistNerf * result, 2.0)

        if mods.contains(where: { $0 is ModHidden }) {
            result *= 1.0 + HIDDEN_BONUS
        } else if mods.contains(where: { $0 is ModTraceable }) {
            result *= 1.0 + (current.obj is HitCircle ? TRACEABLE_CIRCLE_BONUS : TRACEABLE_OBJECT_BONUS)
        }

        result *= MIN_ANGLE_MULTIPLIER + (1.0 - MIN_ANGLE_MULTIPLIER) / (angleRepeatCount + 1.0)

        var sliderBonus = 0.0

        if let slider = current.obj as? Slider, withSliders {
            let pixelTravelDistance = current.lazyTravelDistance / scalingFactor
            sliderBonus = pow(max(0.0, pixelTravelDistance / current.travelTime - MIN_VELOCITY), 0.5)
            sliderBonus *= pixelTravelDistance
            if slider.repeatCount > 0 {
                sliderBonus /= Double(slider.repeatCount + 1)
            }
        }

        result += sliderBonus * SLIDER_MULTIPLIER
        return result
    }
}
