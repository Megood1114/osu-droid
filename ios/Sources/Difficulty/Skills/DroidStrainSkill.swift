import Foundation

open class DroidStrainSkill: StrainSkill<DroidDifficultyHitObject> {
    open var starsPerDouble: Double { fatalError("starsPerDouble must be overridden") }

    public override func process(current: DroidDifficultyHitObject) {
        if current.index < 0 {
            return
        }
        super.process(current: current)
    }

    public override func difficultyValue() -> Double {
        var peaks = currentStrainPeaks
        reduceHighestStrainPeaks(&peaks)

        let starsPerDoubleLog2 = log2(starsPerDouble)

        difficulty = peaks.reduce(0.0) { acc, strain in
            acc + pow(strain, 1.0 / starsPerDoubleLog2)
        }
        difficulty = pow(difficulty, starsPerDoubleLog2)

        return difficulty
    }

    public override func calculateCurrentSectionStart(current: DroidDifficultyHitObject) -> Double {
        return current.startTime
    }
}
