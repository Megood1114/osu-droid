import Foundation

open class StandardStrainSkill: StrainSkill<StandardDifficultyHitObject> {
    open var decayWeight: Double { return 0.9 }

    public override func difficultyValue() -> Double {
        var peaks = currentStrainPeaks
        reduceHighestStrainPeaks(&peaks)

        peaks.sort(by: >)

        difficulty = 0.0
        var weight = 1.0

        for strain in peaks {
            difficulty += strain * weight
            weight *= decayWeight
        }

        return difficulty
    }
}
