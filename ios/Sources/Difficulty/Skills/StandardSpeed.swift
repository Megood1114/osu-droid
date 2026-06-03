import Foundation

public final class StandardSpeed: StandardStrainSkill {
    public override var reducedSectionCount: Int { return 5 }

    private var currentStrain = 0.0
    private var maxStrain = 0.0
    private var currentRhythm = 0.0
    private let skillMultiplier = 1.47
    private let strainDecayBase = 0.3

    private var sliderStrains = [Double]()

    public func relevantNoteCount() -> Double {
        if objectStrains.isEmpty || maxStrain == 0.0 {
            return 0.0
        }

        return objectStrains.reduce(0.0) { acc, d in
            acc + 1.0 / (1.0 + exp(-(d / maxStrain * 12.0 - 6.0)))
        }
    }

    public func countTopWeightedSliders() -> Double {
        return StrainUtils.countTopWeightedSliders(sliderStrains: sliderStrains, difficulty: difficulty)
    }

    public override func strainValueAt(current: StandardDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.strainTime)
        currentStrain += StandardSpeedEvaluator.evaluateDifficultyOf(current: current, mods: mods) * skillMultiplier

        currentRhythm = StandardRhythmEvaluator.evaluateDifficultyOf(current: current)
        let totalStrain = currentStrain * currentRhythm

        maxStrain = max(maxStrain, totalStrain)
        objectStrains.append(totalStrain)

        if current.obj is Slider {
            sliderStrains.append(totalStrain)
        }

        return totalStrain
    }

    public override func calculateInitialStrain(time: Double, current: StandardDifficultyHitObject) -> Double {
        return currentStrain * currentRhythm * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }
}
