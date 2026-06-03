import Foundation

/// Holds data that can be used to calculate osu!standard performance points.
public class StandardDifficultyAttributes: DifficultyAttributes {
    /// The difficulty corresponding to the speed skill.
    public var speedDifficulty: Double = 0.0

    /// The amount of strains that are considered difficult with respect to the speed skill.
    public var speedDifficultStrainCount: Double = 0.0

    /// Describes how much of `speedDifficultStrainCount` is contributed to by HitCircles or Sliders.
    /// A value closer to 0 indicates most of `speedDifficultStrainCount` is contributed by HitCircles.
    /// A value closer to infinity indicates most of `speedDifficultStrainCount` is contributed by Sliders.
    public var speedTopWeightedSliderFactor: Double = 0.0

    /// The perceived approach rate **exclusive** of track rate mods (DT/HT/etc.).
    public var approachRate: Double = 0.0
}
