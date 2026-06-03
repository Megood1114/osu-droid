import Foundation

/// Represents a hit object that can be nested into a `Slider`.
class SliderHitObject: HitObject {
    /// Creates a new `SliderHitObject`.
    ///
    /// - Parameters:
    ///   - startTime: The time at which this `SliderHitObject` starts, in milliseconds.
    ///   - position: The position of this `SliderHitObject` relative to the play field.
    init(startTime: Double, position: Vector2) {
        super.init(startTime: startTime, position: position, isNewCombo: false, comboOffset: 0)
    }
}
