/// Represents a `ControlPoint` that applies an effect to a beatmap.
class EffectControlPoint: ControlPoint {
    /// Whether kiai time is enabled at this `EffectControlPoint`.
    let isKiai: Bool

    /// Creates a new `EffectControlPoint`.
    ///
    /// - Parameters:
    ///   - time: The time at which this control point takes effect, in milliseconds.
    ///   - isKiai: Whether kiai time is enabled.
    init(time: Double, isKiai: Bool) {
        self.isKiai = isKiai
        super.init(time: time)
    }

    override func isRedundant(existing: ControlPoint) -> Bool {
        guard let existing = existing as? EffectControlPoint else {
            return false
        }

        return isKiai == existing.isKiai
    }
}
