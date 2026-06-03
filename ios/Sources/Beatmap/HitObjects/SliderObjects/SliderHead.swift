import Foundation

/// Represents the head of a `Slider`.
class SliderHead: SliderHitObject {
    /// Creates a new `SliderHead`.
    ///
    /// - Parameters:
    ///   - startTime: The start time of this `SliderHead`, in milliseconds.
    ///   - position: The position of this `SliderHead` relative to the play field.
    override init(startTime: Double, position: Vector2) {
        super.init(startTime: startTime, position: position)
    }
}
