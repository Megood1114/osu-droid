import Foundation

public final class StandardAimEvaluator {
    private static let WIDE_ANGLE_MULTIPLIER = 1.5
    private static let ACUTE_ANGLE_MULTIPLIER = 2.55
    private static let SLIDER_MULTIPLIER = 1.35
    private static let VELOCITY_CHANGE_MULTIPLIER = 0.75
    private static let WIGGLE_MULTIPLIER = 1.02

    public static func evaluateDifficultyOf(current: StandardDifficultyHitObject, withSliders: Bool) -> Double {
        if current.obj is Spinner || current.index <= 1 || current.previous(0)!.obj is Spinner {
            return 0.0
        }

        let last = current.previous(0)!
        let lastLast = current.previous(1)!
        let last2 = current.previous(2)

        let radius = Double(DifficultyHitObject.normalizedRadius)
        let diameter = Double(DifficultyHitObject.normalizedDiameter)

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
                    DifficultyCalculationUtils.smootherstep(x: DifficultyCalculationUtils.millisecondsToBPM(milliseconds: current.strainTime, delimiter: 2), start: 300.0, end: 400.0) *
                    DifficultyCalculationUtils.smootherstep(x: current.lazyJumpDistance, start: diameter, end: diameter * 2.0)
            }

            wideAngleBonus = calculateWideAngleBonus(angle: currentAngle)
            wideAngleBonus *= 1.0 - min(wideAngleBonus, pow(calculateWideAngleBonus(angle: lastAngle), 3.0))
            wideAngleBonus *= angleBonus * DifficultyCalculationUtils.smootherstep(x: current.lazyJumpDistance, start: 0.0, end: diameter)

            wiggleBonus = angleBonus *
                DifficultyCalculationUtils.smootherstep(x: current.lazyJumpDistance, start: radius, end: diameter) *
                pow(Interpolation.reverseLinear(x: current.lazyJumpDistance, start: diameter * 3.0, end: diameter), 1.8) *
                DifficultyCalculationUtils.smootherstep(x: currentAngle, start: 110.0.toRadians(), end: 60.0.toRadians()) *
                DifficultyCalculationUtils.smootherstep(x: last.lazyJumpDistance, start: radius, end: diameter) *
                pow(Interpolation.reverseLinear(x: last.lazyJumpDistance, start: diameter * 3.0, end: diameter), 1.8) *
                DifficultyCalculationUtils.smootherstep(x: lastAngle, start: 110.0.toRadians(), end: 60.0.toRadians())

            if let last2 = last2 {
                let distanceSquared = Double(last2.obj.difficultyStackedPosition.getDistanceSquared(last.obj.difficultyStackedPosition))
                if distanceSquared < 1.0 {
                    let distance = sqrt(distanceSquared)
                    wideAngleBonus *= 1.0 - 0.35 * (1.0 - distance)
                }
            }
        }

        if max(prevVelocity, currentVelocity) != 0.0 {
            prevVelocity = (last.lazyJumpDistance + lastLast.travelDistance) / last.strainTime
            currentVelocity = (current.lazyJumpDistance + last.travelDistance) / current.strainTime

            let distanceRatio = DifficultyCalculationUtils.smoothstep(x: abs(prevVelocity - currentVelocity) / max(prevVelocity, currentVelocity), start: 0.0, end: 1.0)
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
            strain += sliderBonus * SLIDER_MULTIPLIER
        }

        return strain
    }

    private static func calculateWideAngleBonus(angle: Double) -> Double {
        return DifficultyCalculationUtils.smoothstep(x: angle, start: 40.0.toRadians(), end: 140.0.toRadians())
    }

    private static func calculateAcuteAngleBonus(angle: Double) -> Double {
        return DifficultyCalculationUtils.smoothstep(x: angle, start: 140.0.toRadians(), end: 40.0.toRadians())
    }
}
