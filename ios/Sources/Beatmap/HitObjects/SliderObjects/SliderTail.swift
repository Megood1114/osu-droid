import Foundation

/// Represents the tail of a `Slider`.
class SliderTail: SliderEndCircle {
    /// Creates a new `SliderTail`.
    ///
    /// - Parameter slider: The `Slider` to which this `SliderTail` belongs.
    init(slider: Slider) {
        super.init(slider: slider, spanIndex: slider.repeatCount)
    }
}
