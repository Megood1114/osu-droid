import Foundation

/// Represents a hit circle.
class HitCircle: HitObject {
    /// Creates a new `HitCircle`.
    ///
    /// - Parameters:
    ///   - startTime: The start time of this `HitCircle`, in milliseconds.
    ///   - position: The position of this `HitCircle` relative to the play field.
    ///   - isNewCombo: Whether this `HitCircle` starts a new combo.
    ///   - comboOffset: When starting a new combo, the offset of the new combo relative to the current one.
    override init(startTime: Double, position: Vector2, isNewCombo: Bool, comboOffset: Int) {
        super.init(startTime: startTime, position: position, isNewCombo: isNewCombo, comboOffset: comboOffset)
    }
}
