import Foundation

public final class StandardFlashlight: StandardStrainSkill {
    public override var reducedSectionCount: Int { return 0 }
    public override var reducedSectionBaseline: Double { return 1.0 }
    public override var decayWeight: Double { return 1.0 }

    private var currentStrain = 0.0
    private let skillMultiplier = 0.05512
    private let strainDecayBase = 0.15

    public override func strainValueAt(current: StandardDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.deltaTime)
        currentStrain += StandardFlashlightEvaluator.evaluateDifficultyOf(current: current, mods: mods) * skillMultiplier

        return currentStrain
    }

    public override func calculateInitialStrain(time: Double, current: StandardDifficultyHitObject) -> Double {
        return currentStrain * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    public override func difficultyValue() -> Double {
        return currentStrainPeaks.reduce(0.0, +)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }

    public static func difficultyToPerformance(difficulty: Double) -> Double {
        return pow(difficulty, 2.0) * 25.0
    }
}
