import Foundation

public final class DroidFlashlight: DroidStrainSkill {
    public override var starsPerDouble: Double { return 1.06 }

    public override var reducedSectionCount: Int { return 0 }
    public override var reducedSectionBaseline: Double { return 1.0 }

    public let withSliders: Bool

    private var currentStrain = 0.0
    private let skillMultiplier = 0.023
    private let strainDecayBase = 0.15

    public init(mods: [Mod], withSliders: Bool) {
        self.withSliders = withSliders
        super.init(mods: mods)
    }

    public override func difficultyValue() -> Double {
        return currentStrainPeaks.reduce(0.0, +) * starsPerDouble
    }

    public override func strainValueAt(current: DroidDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.deltaTime)
        currentStrain += DroidFlashlightEvaluator.evaluateDifficultyOf(current: current, mods: mods, withSliders: withSliders) * skillMultiplier

        objectStrains.append(currentStrain)
        return currentStrain
    }

    public override func calculateInitialStrain(time: Double, current: DroidDifficultyHitObject) -> Double {
        return currentStrain * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }

    public static func difficultyToPerformance(difficulty: Double) -> Double {
        return pow(difficulty, 1.6) * 25.0
    }
}
