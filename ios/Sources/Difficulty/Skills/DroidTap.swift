import Foundation

public final class DroidTap: DroidStrainSkill {
    public override var starsPerDouble: Double { return 1.1 }

    public let considerCheesability: Bool
    public let strainTimeCap: Double?

    private var currentStrain = 0.0
    private var currentRhythm = 0.0

    private let skillMultiplier = 1.375
    private let strainDecayBase = 0.3

    private var objectDeltaTimes = [Double]()
    private var maxStrain = 0.0

    public init(mods: [Mod], considerCheesability: Bool, strainTimeCap: Double? = nil) {
        self.considerCheesability = considerCheesability
        self.strainTimeCap = strainTimeCap
        super.init(mods: mods)
    }

    public func relevantNoteCount() -> Double {
        if objectStrains.isEmpty || maxStrain == 0.0 {
            return 0.0
        }

        return objectStrains.reduce(0.0) { acc, d in
            acc + 1.0 / (1.0 + exp(-(d / maxStrain * 12.0 - 6.0)))
        }
    }

    public func relevantDeltaTime() -> Double {
        if objectStrains.isEmpty || maxStrain == 0.0 {
            return 0.0
        }

        let numerator = objectDeltaTimes.enumerated().reduce(0.0) { acc, tuple in
            let (i, d) = tuple
            return acc + d / (1.0 + exp(-(objectStrains[i] / maxStrain * 25.0 - 20.0)))
        }

        let denominator = objectStrains.reduce(0.0) { acc, d in
            acc + 1.0 / (1.0 + exp(-(d / maxStrain * 25.0 - 20.0)))
        }

        return numerator / denominator
    }

    public override func strainValueAt(current: DroidDifficultyHitObject) -> Double {
        currentStrain *= strainDecay(ms: current.strainTime)
        currentStrain += DroidTapEvaluator.evaluateDifficultyOf(current: current, considerCheesability: considerCheesability, strainTimeCap: strainTimeCap) * skillMultiplier

        currentRhythm = current.rhythmMultiplier

        let totalStrain = currentStrain * currentRhythm

        maxStrain = max(maxStrain, totalStrain)
        objectStrains.append(totalStrain)
        objectDeltaTimes.append(current.deltaTime)

        return totalStrain
    }

    public override func calculateInitialStrain(time: Double, current: DroidDifficultyHitObject) -> Double {
        return currentStrain * currentRhythm * strainDecay(ms: time - current.previous(0)!.startTime)
    }

    private func strainDecay(ms: Double) -> Double {
        return pow(strainDecayBase, ms / 1000.0)
    }
}
