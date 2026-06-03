import Foundation

/// Represents a Slider that is considered difficult.
public struct DifficultSlider {
    /// The index of the Slider in the Beatmap.
    public let index: Int

    /// The difficulty rating of this Slider compared to other Sliders, based on the velocity of the Slider.
    ///
    /// A value closer to 1 indicates that this Slider is more difficult compared to most Sliders.
    /// A value closer to 0 indicates that this Slider is easier compared to most Sliders.
    public let difficultyRating: Double

    public init(index: Int, difficultyRating: Double) {
        self.index = index
        self.difficultyRating = difficultyRating
    }
}
