import Foundation

/// Represents a Beatmap's section at which the strains of HitObjects are considerably high.
open class HighStrainSection {
    /// The index of the first HitObject in this HighStrainSection with respect to the full Beatmap.
    public let firstObjectIndex: Int

    /// The index of the last HitObject in this HighStrainSection with respect to the full Beatmap.
    public let lastObjectIndex: Int

    /// The summed strain of this HighStrainSection.
    public let sumStrain: Double

    public init(firstObjectIndex: Int, lastObjectIndex: Int, sumStrain: Double) {
        self.firstObjectIndex = firstObjectIndex
        self.lastObjectIndex = lastObjectIndex
        self.sumStrain = sumStrain
    }
}
