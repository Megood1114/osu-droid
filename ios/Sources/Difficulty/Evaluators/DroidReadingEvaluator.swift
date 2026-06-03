import Foundation

public final class DroidReadingEvaluator {
    private static let EMPTY_MODS: [Mod] = []
    private static let READING_WINDOW_SIZE = 3000.0
    private static let DISTANCE_INFLUENCE_THRESHOLD = Double(DifficultyHitObject.normalizedDiameter) * 1.25
    private static let HIDDEN_MULTIPLIER = 0.5
    private static let DENSITY_MULTIPLIER = 0.8
    private static let DENSITY_DIFFICULTY_BASE = 1.5
    private static let PREEMPT_BALANCING_FACTOR = 220000.0
    private static let PREEMPT_STARTING_POINT = 475.0

    public static func evaluateDifficultyOf(current: DroidDifficultyHitObject, clockRate: Double, mods: [Mod]) -> Double {
        if current.obj is Spinner || current.isOverlapping(considerDistance: true) || current.index <= 0 {
            return 0.0
        }

        let constantAngleNerfFactor = getConstantAngleNerfFactor(current: current)
        let velocityFactor = max(1.0, current.minimumJumpDistance / current.strainTime)

        var pastObjectDifficultyInfluence = 0.0

        for prev in retrievePastVisibleObjects(current: current) {
            var prevDifficulty = current.opacityAt(time: prev.obj.startTime, mods: EMPTY_MODS)

            prevDifficulty *= DifficultyCalculationUtils.smootherstep(x: prev.lazyJumpDistance, start: 15.0, end: DISTANCE_INFLUENCE_THRESHOLD)
            prevDifficulty *= getTimeNerfFactor(deltaTime: current.startTime - prev.startTime)

            pastObjectDifficultyInfluence += prevDifficulty
        }

        var noteDensityDifficulty = pow(pastObjectDifficultyInfluence, 1.45) * 0.9 * constantAngleNerfFactor * velocityFactor
        noteDensityDifficulty = max(0.0, noteDensityDifficulty - DENSITY_DIFFICULTY_BASE)
        noteDensityDifficulty = pow(noteDensityDifficulty, 0.8) * DENSITY_MULTIPLIER

        var hiddenDifficulty = 0.0

        if mods.contains(where: { $0 is ModHidden }) {
            let timeSpentInvisible = getDurationSpentInvisible(current: current) / clockRate
            let timeSpentInvisibleFactor = pow(timeSpentInvisible, 2.1) * 0.0001

            let futureObjectDifficultyInfluence = calculateCurrentVisibleObjectsDensity(current: current)
            let densityFactor = pow(max(1.0, futureObjectDifficultyInfluence + pastObjectDifficultyInfluence - 2.0), 2.3) * 3.2

            hiddenDifficulty += (timeSpentInvisibleFactor + densityFactor) * constantAngleNerfFactor * velocityFactor * 0.007
            hiddenDifficulty = pow(hiddenDifficulty, 0.85) * HIDDEN_MULTIPLIER

            let prev = current.previous(0) as! DroidDifficultyHitObject

            if current.lazyJumpDistance == 0.0 &&
                current.opacityAt(time: prev.obj.startTime + prev.timePreempt, mods: mods) == 0.0 &&
                prev.startTime + prev.timePreempt > current.startTime {
                hiddenDifficulty += (HIDDEN_MULTIPLIER * 1303.0) / pow(current.strainTime, 1.5)
            }
        }

        let preemptDifficulty = pow((PREEMPT_STARTING_POINT - current.timePreempt + abs(current.timePreempt - PREEMPT_STARTING_POINT)) / 2.0, 2.35) /
            PREEMPT_BALANCING_FACTOR *
            constantAngleNerfFactor *
            velocityFactor

        var sliderDifficulty = 0.0

        if let slider = current.obj as? Slider {
            let scalingFactor = 50.0 / slider.difficultyRadius

            let pixelTravelDistance = current.lazyTravelDistance / scalingFactor
            let currentVelocity = pixelTravelDistance / current.travelTime
            let spanTravelDistance = pixelTravelDistance / Double(slider.spanCount)

            sliderDifficulty += min(4.0, currentVelocity * 0.8) * (spanTravelDistance / 125.0)

            var cumulativeStrainTime = 0.0

            for i in 0..<min(current.index, 4) {
                guard let last = current.previous(i) as? DroidDifficultyHitObject else { break }

                cumulativeStrainTime += last.strainTime

                if !(last.obj is Slider) || last.isOverlapping(considerDistance: true) {
                    continue
                }

                let lastSlider = last.obj as! Slider
                let lastPixelTravelDistance = last.lazyTravelDistance / scalingFactor
                let lastVelocity = lastPixelTravelDistance / last.travelTime
                let lastSpanTravelDistance = lastPixelTravelDistance / Double(lastSlider.spanCount)

                sliderDifficulty += min(4.0, 0.8 * abs(currentVelocity - lastVelocity)) *
                    (lastSpanTravelDistance / 150.0) *
                    min(1.0, 250.0 / cumulativeStrainTime)
            }
        }

        return noteDensityDifficulty + hiddenDifficulty + preemptDifficulty + sliderDifficulty
    }

    private static func retrievePastVisibleObjects(current: DroidDifficultyHitObject) -> [DroidDifficultyHitObject] {
        var visibleObjects = [DroidDifficultyHitObject]()
        
        for i in 0..<current.index {
            guard let prev = current.previous(i) as? DroidDifficultyHitObject else { break }

            if current.startTime - prev.startTime > READING_WINDOW_SIZE ||
                prev.startTime + prev.timePreempt < current.startTime {
                break
            }

            if prev.isOverlapping(considerDistance: true) {
                continue
            }

            visibleObjects.append(prev)
        }
        
        return visibleObjects
    }

    private static func calculateCurrentVisibleObjectsDensity(current: DroidDifficultyHitObject) -> Double {
        var visibleObjectCount = 0.0
        var nextObj = current.next(0) as? DroidDifficultyHitObject

        while let next = nextObj {
            let timeDifference = next.startTime - current.startTime

            if timeDifference > READING_WINDOW_SIZE ||
                current.startTime + current.timePreempt < next.startTime {
                break
            }

            if next.isOverlapping(considerDistance: true) {
                nextObj = next.next(0) as? DroidDifficultyHitObject
                continue
            }

            let timeNerfFactor = getTimeNerfFactor(deltaTime: timeDifference)

            visibleObjectCount += next.opacityAt(time: current.obj.startTime, mods: EMPTY_MODS) * timeNerfFactor

            nextObj = next.next(0) as? DroidDifficultyHitObject
        }

        return visibleObjectCount
    }

    private static func getDurationSpentInvisible(current: DroidDifficultyHitObject) -> Double {
        let obj = current.obj

        let fadeOutStartTime = obj.startTime - obj.timePreempt + obj.timeFadeIn
        let fadeOutDuration = obj.timePreempt * ModHidden.fadeOutDurationMultiplier

        return fadeOutStartTime + fadeOutDuration - (obj.startTime - obj.timePreempt)
    }

    private static func getConstantAngleNerfFactor(current: DroidDifficultyHitObject) -> Double {
        let maxTimeLimit = 2000.0
        let minTimeLimit = 200.0

        var constantAngleCount = 0.0
        var index = 0
        var currentTimeGap = 0.0

        while currentTimeGap < maxTimeLimit {
            guard let loopObj = current.previous(index) else { break }

            if let currentAngle = current.angle, let loopAngle = loopObj.angle {
                let angleDifference = abs(currentAngle - loopAngle)

                let longIntervalFactor = max(0.0, min(1.0, 1.0 - (loopObj.strainTime - minTimeLimit) / (maxTimeLimit - minTimeLimit)))

                constantAngleCount += cos(3.0 * min(Double.pi / 6.0, angleDifference)) * longIntervalFactor
            }

            currentTimeGap = current.startTime - loopObj.startTime
            index += 1
        }

        return max(0.2, min(1.0, 2.0 / constantAngleCount))
    }

    private static func getTimeNerfFactor(deltaTime: Double) -> Double {
        return max(0.0, min(1.0, 2.0 - deltaTime / (READING_WINDOW_SIZE / 2.0)))
    }
}
