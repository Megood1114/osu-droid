import Foundation

/// Holds data that can be used to calculate osu!droid performance points.
public class DroidDifficultyAttributes: DifficultyAttributes {
    /// The difficulty corresponding to the tap skill.
    public var tapDifficulty: Double = 0.0

    /// The difficulty corresponding to the rhythm skill.
    public var rhythmDifficulty: Double = 0.0

    /// The difficulty corresponding to the reading skill.
    public var readingDifficulty: Double = 0.0

    /// The amount of strains that are considered difficult with respect to the tap skill.
    public var tapDifficultStrainCount: Double = 0.0

    /// The amount of strains that are considered difficult with respect to the flashlight skill.
    public var flashlightDifficultStrainCount: Double = 0.0

    /// The amount of notes that are considered difficult with respect to the reading skill.
    public var readingDifficultNoteCount: Double = 0.0

    /// The average delta time of speed objects.
    public var averageSpeedDeltaTime: Double = 0.0

    /// Possible sections at which the player can use three fingers on.
    public var possibleThreeFingeredSections: [HighStrainSection] = []

    /// Sliders that are considered difficult.
    public var difficultSliders: [DifficultSlider] = []

    /// Describes how much of flashlight difficulty is contributed to by HitCircles or Sliders.
    /// A value closer to 1 indicates most flashlight difficulty is contributed by HitCircles.
    /// A value closer to 0 indicates most flashlight difficulty is contributed by Sliders.
    public var flashlightSliderFactor: Double = 1.0

    /// Describes how much of tap difficulty is contributed by notes that are "vibroable".
    /// A value closer to 1 indicates most tap difficulty is contributed by notes that are not "vibroable".
    /// A value closer to 0 indicates most tap difficulty is contributed by notes that are "vibroable".
    public var vibroFactor: Double = 1.0
}
