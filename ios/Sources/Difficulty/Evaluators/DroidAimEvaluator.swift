import Foundation

public final class DroidAimEvaluator {
    private static let WIDE_ANGLE_MULTIPLIER = 1.6
    private static let ACUTE_ANGLE_MULTIPLIER = 2.4
    private static let SLIDER_MULTIPLIER = 1.35
    private static let VELOCITY_CHANGE_MULTIPLIER = 0.75
    private static let WIGGLE_MULTIPLIER = 1.02

    private static let SINGLE_SPACING_THRESHOLD = 100.0

    private static let MIN_SPEED_BONUS = 75.0

    public static func evaluateDifficultyOf(current: DroidDifficultyHitObject, withSliders: Bool) -> Double {
        if current.obj is Spinner || current.isOverlapping(true) {
            return 0.0
        }

        return snapAimStrainOf(current: current, withSliders: withSliders) + flowAimStrainOf(current: current)
    }

    private static func snapAimStrainOf(current: DroidDifficultyHitObject, withSliders: Bool) -> Double {
        if current.obj is Spinner || current.index <= 1 || current.previous(0)!.obj is Spinner {
            return 0.0
        }

        let last = current.previous(0)!
        let lastLast = current.previous(1)!
        let last2 = current.previous(2)

        let radius = DifficultyHitObject.NORMALIZED_RADIUS
        let diameter = DifficultyHitObject.NORMALIZED_DIAMETER

        var currentVelocity = current.lazyJumpDistance / current.strainTime

        if last.obj is Slider && withSliders {
            let travelVelocity = last.travelDistance / last.travelTime
            let movementVelocity = current.minimumJumpDistance / current.minimumJumpTime
            currentVelocity = max(currentVelocity, movementVelocity + travelVelocity)
        }

        var prevVelocity = last.lazyJumpDistance / last.strainTime

        if lastLast.obj is Slider && withSliders {
            let travelVelocity = lastLast.travelDistance / lastLast.travelTime
            let movementVelocity = last.minimumJumpDistance / last.minimumJumpTime
            prevVelocity = max(prevVelocity, movementVelocity + travelVelocity)
        }

        var wideAngleBonus = 0.0
        var acuteAngleBonus = 0.0
        var sliderBonus = 0.0
        var velocityChangeBonus = 0.0
        var wiggleBonus = 0.0

        var strain = currentVelocity

        if let currentAngle = current.angle, let lastAngle = last.angle {
            let angleBonus = min(currentVelocity, prevVelocity)

            if max(current.strainTime, last.strainTime) < 1.25 * min(current.strainTime, last.strainTime) {
                acuteAngleBonus = calculateAcuteAngleBonus(angle: currentAngle)
                acuteAngleBonus *= 0.08 + 0.92 * (1.0 - min(acuteAngleBonus, pow(calculateAcuteAngleBonus(angle: lastAngle), 3.0)))
                acuteAngleBonus *= angleBonus *
                    DifficultyCalculationUtils.smootherstep(DifficultyCalculationUtils.millisecondsToBPM(current.strainTime, 2), 300.0, 400.0) *
                    DifficultyCalculationUtils.smootherstep(current.lazyJumpDistance, diameter, diameter * 2.0)
            }

            wideAngleBonus = calculateWideAngleBonus(angle: currentAngle)
            wideAngleBonus *= 1.0 - min(wideAngleBonus, pow(calculateWideAngleBonus(angle: lastAngle), 3.0))
            wideAngleBonus *= angleBonus * DifficultyCalculationUtils.smootherstep(current.lazyJumpDistance, 0.0, diameter)

            wiggleBonus = angleBonus *
                DifficultyCalculationUtils.smootherstep(current.lazyJumpDistance, radius, diameter) *
                pow(Interpolation.reverseLinear(current.lazyJumpDistance, diameter * 3.0, diameter), 1.8) *
                DifficultyCalculationUtils.smootherstep(currentAngle, 110.0.toRadians(), 60.0.toRadians()) *
                DifficultyCalculationUtils.smootherstep(last.lazyJumpDistance, radius, diameter) *
                pow(Interpolation.reverseLinear(last.lazyJumpDistance, diameter * 3.0, diameter), 1.8) *
                DifficultyCalculationUtils.smootherstep(lastAngle, 110.0.toRadians(), 60.0.toRadians())

            if let last2 = last2 {
                let distanceSquared = last2.obj.difficultyStackedPosition.getDistanceSquared(last.obj.difficultyStackedPosition)
                if distanceSquared < 1.0 {
                    let distance = sqrt(Double(distanceSquared))
                    wideAngleBonus *= 1.0 - 0.35 * (1.0 - distance)
                }
            }
        }

        if max(prevVelocity, currentVelocity) != 0.0 {
            prevVelocity = (last.lazyJumpDistance + lastLast.travelDistance) / last.strainTime
            currentVelocity = (current.lazyJumpDistance + last.travelDistance) / current.strainTime

            let distanceRatio = DifficultyCalculationUtils.smoothstep(
                abs(prevVelocity - currentVelocity) / max(prevVelocity, currentVelocity),
                0.0,
                1.0
            )

            let overlapVelocityBuff = min(125.0 / min(current.strainTime, last.strainTime), abs(prevVelocity - currentVelocity))
            velocityChangeBonus = overlapVelocityBuff * distanceRatio
            velocityChangeBonus *= pow(min(current.strainTime, last.strainTime) / max(current.strainTime, last.strainTime), 2.0)
        }

        if last.obj is Slider {
            sliderBonus = last.travelDistance / last.travelTime
        }

        strain += wiggleBonus * WIGGLE_MULTIPLIER
        strain += velocityChangeBonus * VELOCITY_CHANGE_MULTIPLIER
        strain += max(acuteAngleBonus * ACUTE_ANGLE_MULTIPLIER, wideAngleBonus * WIDE_ANGLE_MULTIPLIER)
        strain *= current.smallCircleBonus

        if withSliders {
            strain += pow(1.0 + sliderBonus * SLIDER_MULTIPLIER, 1.25) - 1.0
        }

        return strain
    }

    private static func flowAimStrainOf(current: DroidDifficultyHitObject) -> Double {
        var speedBonus = 1.0

        if current.strainTime < MIN_SPEED_BONUS {
            speedBonus += 0.75 * pow((MIN_SPEED_BONUS - current.strainTime) / 40.0, 2.0)
        }

        let travelDistance = current.previous(0)?.travelDistance ?? 0.0
        let shortDistancePenalty = pow(min(SINGLE_SPACING_THRESHOLD, travelDistance + current.minimumJumpDistance) / SINGLE_SPACING_THRESHOLD, 3.5)

        return 200.0 * speedBonus * sqrt(current.smallCircleBonus) * shortDistancePenalty / current.strainTime
    }

    private static func calculateWideAngleBonus(angle: Double) -> Double {
        return DifficultyCalculationUtils.smoothstep(angle, 40.0.toRadians(), 140.0.toRadians())
    }

    private static func calculateAcuteAngleBonus(angle: Double) -> Double {
        return DifficultyCalculationUtils.smoothstep(angle, 140.0.toRadians(), 40.0.toRadians())
    }
}
