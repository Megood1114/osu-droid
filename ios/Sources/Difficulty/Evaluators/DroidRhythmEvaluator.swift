import Foundation

public final class DroidRhythmEvaluator {
    private static let HISTORY_TIME_MAX = 5.0 * 1000.0
    private static let HISTORY_OBJECTS_MAX = 32
    private static let RHYTHM_OVERALL_MULTIPLIER = 0.95
    private static let RHYTHM_RATIO_MULTIPLIER = 15.0

    public static func evaluateDifficultyOf(current: DroidDifficultyHitObject, useSliderAccuracy: Bool) -> Double {
        if current.obj is Spinner {
            return 1.0
        }

        let deltaDifferenceEpsilon = current.fullGreatWindow * 0.3
        var rhythmComplexitySum = 0.0

        var island = Island(epsilon: deltaDifferenceEpsilon)
        var previousIsland = Island(epsilon: deltaDifferenceEpsilon)
        var islandCounts = [Island: Int]()

        var startRatio = 0.0
        var firstDeltaSwitch = false
        var rhythmStart = 0

        let historicalNoteCount = min(current.index, HISTORY_OBJECTS_MAX)

        var validPrevious = [DroidDifficultyHitObject]()

        for i in 0..<historicalNoteCount {
            if let prev = current.previous(i) as? DroidDifficultyHitObject {
                if !prev.isOverlapping(considerDistance: false) {
                    validPrevious.append(prev)
                }
            } else {
                break
            }
        }

        if validPrevious.count < 3 {
            return 1.0
        }

        while rhythmStart < validPrevious.count - 2 &&
                current.startTime - validPrevious[rhythmStart].startTime < HISTORY_TIME_MAX {
            rhythmStart += 1
        }

        var prevObject = validPrevious[rhythmStart]
        var lastObject = validPrevious[rhythmStart + 1]

        for i in stride(from: rhythmStart, through: 1, by: -1) {
            let currentObject = validPrevious[i - 1]

            let timeDecay = (HISTORY_TIME_MAX - (current.startTime - currentObject.startTime)) / HISTORY_TIME_MAX
            let noteDecay = Double(validPrevious.count - i) / Double(validPrevious.count)

            let currentHistoricalDecay = min(noteDecay, timeDecay)

            let currentDelta = max(currentObject.deltaTime, 1e-7)
            let prevDelta = max(prevObject.deltaTime, 1e-7)
            let lastDelta = max(lastObject.deltaTime, 1e-7)

            let deltaDifference = max(prevDelta, currentDelta) / min(prevDelta, currentDelta)
            let deltaDifferenceFraction = deltaDifference - trunc(deltaDifference)

            let currentRatio = 1.0 + RHYTHM_RATIO_MULTIPLIER * min(0.5, DifficultyCalculationUtils.smoothstepBellCurve(x: deltaDifferenceFraction))

            let differenceMultiplier = max(0.0, min(1.0, 2.0 - deltaDifference / 8.0))
            let windowPenalty = max(0.0, min(1.0, (abs(prevDelta - currentDelta) - deltaDifferenceEpsilon) / deltaDifferenceEpsilon))

            var effectiveRatio = windowPenalty * currentRatio * differenceMultiplier

            if firstDeltaSwitch {
                if abs(prevDelta - currentDelta) < deltaDifferenceEpsilon {
                    island.addDelta(delta: Int(currentDelta))
                } else {
                    if !useSliderAccuracy {
                        if currentObject.obj is Slider {
                            effectiveRatio /= 8.0
                        }

                        if prevObject.obj is Slider {
                            effectiveRatio *= 0.3
                        }
                    }

                    if island.isSimilarPolarity(other: previousIsland) {
                        effectiveRatio /= 2.0
                    }

                    if lastDelta > prevDelta + deltaDifferenceEpsilon && prevDelta > currentDelta + deltaDifferenceEpsilon {
                        effectiveRatio /= 8.0
                    }

                    if previousIsland.deltaCount == island.deltaCount {
                        effectiveRatio /= 2.0
                    }

                    var islandFound = false

                    for (otherIsland, count) in islandCounts {
                        if island != otherIsland {
                            continue
                        }

                        islandFound = true
                        var islandCount = count

                        if previousIsland == island {
                            islandCount += 1
                            islandCounts[otherIsland] = islandCount
                        }

                        effectiveRatio *= min(
                            3.0 / Double(islandCount),
                            pow(1.0 / Double(islandCount), DifficultyCalculationUtils.logistic(x: Double(island.delta), midpointOffset: 58.33, multiplier: 0.24, maxValue: 2.75))
                        )

                        break
                    }

                    if !islandFound {
                        islandCounts[island] = 1
                    }

                    effectiveRatio *= 1.0 - prevObject.getDoubletapness(nextObj: prevObject.next(0)) * 0.75

                    rhythmComplexitySum += sqrt(effectiveRatio * startRatio) * currentHistoricalDecay

                    startRatio = effectiveRatio
                    previousIsland = island

                    if prevDelta + deltaDifferenceEpsilon < currentDelta {
                        firstDeltaSwitch = false
                    }

                    island = Island(delta: Int(currentDelta), deltaDifferenceEpsilon: deltaDifferenceEpsilon)
                }
            } else if prevDelta > currentDelta + deltaDifferenceEpsilon {
                firstDeltaSwitch = true

                if currentObject.obj is Slider {
                    effectiveRatio *= 0.6
                }

                if prevObject.obj is Slider {
                    effectiveRatio *= 0.6
                }

                startRatio = effectiveRatio

                island = Island(delta: Int(currentDelta), deltaDifferenceEpsilon: deltaDifferenceEpsilon)
            }

            lastObject = prevObject
            prevObject = currentObject
        }

        return sqrt(4.0 + rhythmComplexitySum * RHYTHM_OVERALL_MULTIPLIER) / 2.0
    }
}
