import Foundation

/// Represents a slider repeat.
class SliderRepeat: SliderEndCircle {
    /// Creates a new `SliderRepeat`.
    ///
    /// - Parameters:
    ///   - slider: The slider to which this `SliderRepeat` belongs.
    ///   - spanIndex: The index of the span at which this `SliderRepeat` lies.
    override init(slider: Slider, spanIndex: Int) {
        super.init(slider: slider, spanIndex: spanIndex)
    }
}
