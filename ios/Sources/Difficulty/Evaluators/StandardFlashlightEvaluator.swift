import Foundation

public final class StandardFlashlightEvaluator {
    public static func evaluateDifficultyOf(current: StandardDifficultyHitObject, mods: [Mod]) -> Double {
        if current.obj is Spinner {
            return 0.0
        }

        let scalingFactor = 52.0 / current.obj.difficultyRadius
        var smallDistNerf = 1.0
        var cumulativeStrainTime = 0.0
        var result = 0.0
        var last = current
        var angleRepeatCount = 0.0

        for i in 0..<min(current.index, 10) {
            let currentObject = current.previous(i) as! StandardDifficultyHitObject

            cumulativeStrainTime += last.strainTime

            if !(currentObject.obj is Spinner) {
                let jumpDistance = current.obj.difficultyStackedPosition.getDistance(currentObject.obj.difficultyStackedEndPosition)

                if i == 0 {
                    smallDistNerf = min(1.0, jumpDistance / 75.0)
                }

                let stackNerf = min(1.0, currentObject.lazyJumpDistance / scalingFactor / 25.0)
                let opacityBonus = 1.0 + 0.4 * (1.0 - current.opacityAt(currentObject.obj.startTime, mods))

                result += stackNerf * opacityBonus * scalingFactor * jumpDistance / cumulativeStrainTime

                if let currentObjectAngle = currentObject.angle, let currentAngle = current.angle, abs(currentObjectAngle - currentAngle) < 0.02 {
                    angleRepeatCount += max(0.0, 1.0 - 0.1 * Double(i))
                }
            }

            last = currentObject
        }

        result = pow(smallDistNerf * result, 2.0)

        if mods.contains(where: { $0 is ModHidden }) {
            let hiddenBonus = 0.2
            result *= 1.0 + hiddenBonus
        }

        let minAngleMultiplier = 0.2
        result *= minAngleMultiplier + (1.0 - minAngleMultiplier) / (angleRepeatCount + 1.0)

        var sliderBonus = 0.0
        if let slider = current.obj as? Slider {
            let pixelTravelDistance = current.lazyTravelDistance / scalingFactor
            let minVelocity = 0.5
            sliderBonus = pow(max(0.0, pixelTravelDistance / current.travelTime - minVelocity), 0.5)
            sliderBonus *= pixelTravelDistance
            sliderBonus /= Double(slider.repeatCount + 1)
        }

        let sliderMultiplier = 1.3
        result += sliderBonus * sliderMultiplier

        return result
    }
}
