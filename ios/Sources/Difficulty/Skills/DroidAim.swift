import Foundation

public final class DroidAim: DroidStrainSkill {
    public override var starsPerDouble: Double { return 1.05 }

    public let withSliders: Bool

    public var sliderVelocities = [DifficultSlider]()

    private var sliderStrains = [Double]()
    private var maxSliderStrain = 0.0

    private var currentStrain = 0.0
    private let skillMultiplier = 26.5
    private let strainDecayBase = 0.15

    public init(mods: [Mod], withSliders: Bool) {
        self.withSliders = withSliders
        super.init(mods: mods)
    }

    public func countDifficultSliders() -> Double {
        if sliderStrains.isEmpty || maxSliderStrain == 0.0 {
            return 0.0
        }

        return sliderStrains.reduce(0.0) { total, strain in
            total + 1.0 / (1.0 + exp(-(strain / maxSliderStrain * 12.0 - 6.0)))
        }
    }

    public override func strainValueAt(current: DroidDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.deltaTime)
        currentStrain += DroidAimEvaluator.evaluateDifficultyOf(current: current, withSliders: withSliders) * skillMultiplier

        let velocity = current.travelDistance / current.travelTime

        if velocity > 0 {
            sliderVelocities.append(DifficultSlider(index: current.index + 1, velocity: velocity))
        }

        if current.obj is Slider {
            sliderStrains.append(currentStrain)
            maxSliderStrain = max(maxSliderStrain, currentStrain)
        }

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
        return StrainSkill.difficultyToPerformance(difficulty: pow(difficulty, 0.8))
    }
}
