import Foundation

open class StrainSkill<TObject: DifficultyHitObject>: Skill<TObject> {
    open var reducedSectionCount: Int { return 10 }
    open var reducedSectionBaseline: Double { return 0.75 }

    public var objectStrains = [Double]()

    public var difficulty: Double = 0.0

    private var strainPeaks = [Double]()
    private var currentSectionPeak = 0.0
    private var currentSectionEnd = 0.0
    private let sectionLength = 400.0

    public override init(mods: [Mod]) {
        super.init(mods: mods)
    }

    public override func process(current: TObject) {
        if current.index == 0 {
            currentSectionEnd = calculateCurrentSectionStart(current: current)
        }

        while current.startTime > currentSectionEnd {
            saveCurrentPeak()
            startNewSectionFrom(time: currentSectionEnd, current: current)
            currentSectionEnd += sectionLength
        }

        currentSectionPeak = max(strainValueAt(current: current), currentSectionPeak)
    }

    public var currentStrainPeaks: [Double] {
        var peaks = strainPeaks
        peaks.append(currentSectionPeak)
        return peaks
    }

    public func countTopWeightedStrains() -> Double {
        if difficulty == 0.0 {
            return 0.0
        }

        let consistentTopStrain = difficulty / 10.0

        if consistentTopStrain == 0.0 {
            return Double(objectStrains.count)
        }

        return objectStrains.reduce(0.0) { acc, strain in
            acc + 1.1 / (1.0 + exp(-10.0 * (strain / consistentTopStrain - 0.88)))
        }
    }

    public func reduceHighestStrainPeaks(_ strainPeaks: inout [Double]) {
        var highestStrainPeakIndices = Array(repeating: -1, count: min(strainPeaks.count, reducedSectionCount))

        if highestStrainPeakIndices.isEmpty {
            return
        }

        for i in 0..<strainPeaks.count {
            let strain = strainPeaks[i]

            let lowestStrainIndex = highestStrainPeakIndices.last!
            let lowestStrain = lowestStrainIndex > -1 ? strainPeaks[lowestStrainIndex] : 0.0

            if strain <= lowestStrain {
                continue
            }

            let insertionIndex = highestStrainPeakIndices.firstIndex(where: {
                strain > ($0 > -1 ? strainPeaks[$0] : 0.0)
            }) ?? highestStrainPeakIndices.count - 1

            if highestStrainPeakIndices.count - 1 >= insertionIndex + 1 {
                for j in stride(from: highestStrainPeakIndices.count - 1, through: insertionIndex + 1, by: -1) {
                    highestStrainPeakIndices[j] = highestStrainPeakIndices[j - 1]
                }
            }

            highestStrainPeakIndices[insertionIndex] = i
        }

        for i in 0..<highestStrainPeakIndices.count {
            let index = highestStrainPeakIndices[i]

            if index == -1 {
                continue
            }

            let scale = log10(Interpolation.linear(1.0, 10.0, Double(i) / Double(reducedSectionCount)))

            strainPeaks[index] *= Interpolation.linear(reducedSectionBaseline, 1.0, scale)
        }
    }

    open func calculateCurrentSectionStart(current: TObject) -> Double {
        return ceil(current.startTime / sectionLength) * sectionLength
    }

    open func strainValueAt(current: TObject) -> Double {
        fatalError("strainValueAt(current:) must be overridden")
    }

    open func calculateInitialStrain(time: Double, current: TObject) -> Double {
        fatalError("calculateInitialStrain(time:current:) must be overridden")
    }

    private func saveCurrentPeak() {
        strainPeaks.append(currentSectionPeak)
    }

    private func startNewSectionFrom(time: Double, current: TObject) {
        currentSectionPeak = calculateInitialStrain(time: time, current: current)
    }

    public static func difficultyToPerformance(difficulty: Double) -> Double {
        return pow(5.0 * max(1.0, difficulty / 0.0675) - 4.0, 3.0) / 100000.0
    }
}
