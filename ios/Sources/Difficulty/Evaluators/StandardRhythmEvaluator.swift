import Foundation

public final class StandardRhythmEvaluator {
    private static let HISTORY_TIME_MAX = 5.0 * 1000.0
    private static let HISTORY_OBJECTS_MAX = 32
    private static let RHYTHM_OVERALL_MULTIPLIER = 1.0
    private static let RHYTHM_RATIO_MULTIPLIER = 15.0

    public static func evaluateDifficultyOf(current: StandardDifficultyHitObject) -> Double {
        if current.obj is Spinner {
            return 0.0
        }

        if current.index <= 1 {
            return 1.0
        }

        var rhythmComplexitySum = 0.0

        let deltaDifferenceEpsilon = current.fullGreatWindow * 0.3

        var island = Island(epsilon: deltaDifferenceEpsilon)
        var previousIsland = Island(epsilon: deltaDifferenceEpsilon)
        var islandCounts = [Island: Int]()

        var startRatio = 0.0
        var firstDeltaSwitch = false
        var rhythmStart = 0
        let historicalNoteCount = min(current.index, HISTORY_OBJECTS_MAX)

        while rhythmStart < historicalNoteCount - 2 &&
                current.startTime - current.previous(rhythmStart)!.startTime < HISTORY_TIME_MAX {
            rhythmStart += 1
        }

        var prevObject = current.previous(rhythmStart)!
        var lastObject = current.previous(rhythmStart + 1)!

        for i in stride(from: rhythmStart, through: 1, by: -1) {
            let currentObject = current.previous(i - 1)!

            let timeDecay = (HISTORY_TIME_MAX - (current.startTime - currentObject.startTime)) / HISTORY_TIME_MAX
            let noteDecay = Double(historicalNoteCount - i) / Double(historicalNoteCount)

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
                    if currentObject.obj is Slider {
                        effectiveRatio /= 8.0
                    }

                    if prevObject.obj is Slider {
                        effectiveRatio *= 0.3
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

        return sqrt(4.0 + rhythmComplexitySum * RHYTHM_OVERALL_MULTIPLIER) / 2.0 * (1.0 - current.getDoubletapness(nextObj: current.next(0)))
    }
}
