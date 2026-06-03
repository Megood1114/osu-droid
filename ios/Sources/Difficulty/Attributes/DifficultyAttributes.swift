import Foundation

/// Holds data that can be used to calculate performance points.
open class DifficultyAttributes {
    /// The overall clock rate that was applied to the beatmap.
    public var clockRate: Double = 1.0

    /// The mods which were applied to the beatmap.
    public var mods: [Mod] = []

    /// The combined star rating of all skills.
    public var starRating: Double = 0.0

    /// The maximum achievable combo.
    public var maxCombo: Int = 0

    /// The difficulty corresponding to the aim skill.
    public var aimDifficulty: Double = 0.0

    /// The difficulty corresponding to the flashlight skill.
    public var flashlightDifficulty: Double = 0.0

    /// The number of clickable objects weighted by difficulty.
    /// Related to speed difficulty.
    public var speedNoteCount: Double = 0.0

    /// Describes how much of aim difficulty is contributed to by HitCircles or Sliders.
    /// A value closer to 1 indicates most aim difficulty is contributed by HitCircles.
    /// A value closer to 0 indicates most aim difficulty is contributed by Sliders.
    public var aimSliderFactor: Double = 0.0

    /// The amount of strains that are considered difficult with respect to the aim skill.
    public var aimDifficultStrainCount: Double = 0.0

    /// The amount of sliders weighted by difficulty.
    public var aimDifficultSliderCount: Double = 0.0

    /// Describes how much of `aimDifficultStrainCount` is contributed to by HitCircles or Sliders.
    /// A value closer to 0 indicates most of `aimDifficultStrainCount` is contributed by HitCircles.
    /// A value closer to infinity indicates most of `aimDifficultStrainCount` is contributed by Sliders.
    public var aimTopWeightedSliderFactor: Double = 0.0

    /// The perceived overall difficulty **exclusive** of track rate mods (DT/HT/etc.).
    public var overallDifficulty: Double = 0.0

    /// The number of HitCircles in the beatmap.
    public var hitCircleCount: Int = 0

    /// The number of Sliders in the beatmap.
    public var sliderCount: Int = 0

    /// The number of Spinners in the beatmap.
    public var spinnerCount: Int = 0

    public init() {}
}
