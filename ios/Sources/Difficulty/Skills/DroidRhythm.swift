import Foundation

public final class DroidRhythm: DroidStrainSkill {
    public override var reducedSectionCount: Int { return 5 }
    public override var starsPerDouble: Double { return 1.75 }

    private var currentStrain = 0.0
    private let strainDecayBase = 0.3

    private let useSliderAccuracy: Bool

    public override init(mods: [Mod]) {
        self.useSliderAccuracy = mods.contains(where: { $0 is ModScoreV2 })
        super.init(mods: mods)
    }

    public override func strainValueAt(current: DroidDifficultyHitObject) -> Double {
        let rhythmMultiplier = DroidRhythmEvaluator.evaluateDifficultyOf(current: current, useSliderAccuracy: useSliderAccuracy)
        let doubletapness = 1.0 - current.getDoubletapness(nextObj: current.next(0))

        current.rhythmMultiplier = rhythmMultiplier * doubletapness

        currentStrain *= strainDecay(ms: current.deltaTime)
        currentStrain += (rhythmMultiplier - 1.0) * doubletapness

        return currentStrain
    }

    public override func calculateInitialStrain(time: Double, current: DroidDifficultyHitObject) -> Double {
        return currentStrain * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }
}
