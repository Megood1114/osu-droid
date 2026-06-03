import Foundation

public final class StandardAim: StandardStrainSkill {
    public let withSliders: Bool

    private var currentStrain = 0.0
    private let skillMultiplier = 26.0
    private let strainDecayBase = 0.15

    private var sliderStrains = [Double]()
    private var maxSliderStrain = 0.0

    public init(mods: [Mod], withSliders: Bool) {
        self.withSliders = withSliders
        super.init(mods: mods)
    }

    public func countDifficultSliders() -> Double {
        if sliderStrains.isEmpty {
            return 0.0
        }

        return sliderStrains.reduce(0.0) { total, strain in
            total + 1.0 / (1.0 + exp(-(strain / maxSliderStrain * 12.0 - 6.0)))
        }
    }

    public func countTopWeightedSliders() -> Double {
        return StrainUtils.countTopWeightedSliders(sliderStrains: sliderStrains, difficulty: difficulty)
    }

    public override func strainValueAt(current: StandardDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.deltaTime)
        currentStrain += StandardAimEvaluator.evaluateDifficultyOf(current: current, withSliders: withSliders) * skillMultiplier

        if current.obj is Slider {
            sliderStrains.append(currentStrain)
            maxSliderStrain = max(maxSliderStrain, currentStrain)
        }

        objectStrains.append(currentStrain)
        return currentStrain
    }

    public override func calculateInitialStrain(time: Double, current: StandardDifficultyHitObject) -> Double {
        return currentStrain * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }
}
