import Foundation

public final class DroidReading: Skill<DroidDifficultyHitObject> {
    private var noteDifficulties = [Double]()

    private let strainDecayBase = 0.8
    private let skillMultiplier = 2.0

    private var currentNoteDifficulty = 0.0

    private var difficulty = 0.0
    private var noteWeightSum = 0.0

    private let clockRate: Double
    private let hitObjects: [HitObject]

    init(mods: [Mod], clockRate: Double, hitObjects: [HitObject]) {
        self.clockRate = clockRate
        self.hitObjects = hitObjects
        super.init(mods: mods)
    }

    public override func process(current: DroidDifficultyHitObject) {
        currentNoteDifficulty *= strainDecay(ms: current.deltaTime)
        currentNoteDifficulty += DroidReadingEvaluator.evaluateDifficultyOf(current: current, clockRate: clockRate, mods: mods) * skillMultiplier

        noteDifficulties.append(currentNoteDifficulty * current.rhythmMultiplier)
    }

    public override func difficultyValue() -> Double {
        if hitObjects.isEmpty {
            return 0.0
        }

        var peaks = noteDifficulties.filter { $0 > 0.0 }

        let reducedDuration = hitObjects[0].startTime / clockRate + 60.0 * 1000.0
        var reducedCount = 0

        for obj in hitObjects {
            if obj.startTime / clockRate > reducedDuration {
                break
            }
            reducedCount += 1
        }

        for i in 0..<min(peaks.count, reducedCount) {
            peaks[i] *= log10(Interpolation.linear(start: 1.0, end: 10.0, amount: max(0.0, min(1.0, Double(i) / Double(reducedCount)))))
        }

        peaks.sort(by: >)
        difficulty = 0.0
        noteWeightSum = 0.0

        for i in 0..<peaks.count {
            let weight = (1.0 + 1.0 / (1.0 + Double(i))) / (pow(Double(i), 0.8) + 1.0 + 1.0 / (1.0 + Double(i)))

            if weight == 0.0 {
                break
            }

            difficulty += peaks[i] * weight
            noteWeightSum += weight
        }

        return difficulty
    }

    public func countTopWeightedNotes() -> Double {
        if noteDifficulties.isEmpty || difficulty == 0.0 || noteWeightSum == 0.0 {
            return 0.0
        }

        let consistentTopNote = difficulty / noteWeightSum

        return noteDifficulties.reduce(0.0) { acc, d in
            acc + 1.1 / (1.0 + exp(-5.0 * (d / consistentTopNote - 1.15)))
        }
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }

    public static func difficultyToPerformance(difficulty: Double) -> Double {
        return pow(pow(difficulty, 2.0) * 25.0, 0.8)
    }
}
