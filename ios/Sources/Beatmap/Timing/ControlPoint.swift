/// Represents a control point.
class ControlPoint {
    /// The time at which this `ControlPoint` takes effect, in milliseconds.
    let time: Double

    /// Creates a new `ControlPoint`.
    ///
    /// - Parameter time: The time at which this control point takes effect, in milliseconds.
    init(time: Double) {
        self.time = time
    }

    /// Determines whether this `ControlPoint` results in a meaningful change when placed alongside another.
    ///
    /// - Parameter existing: An existing `ControlPoint` to compare with.
    /// - Returns: Whether this control point is redundant given the existing one.
    func isRedundant(existing: ControlPoint) -> Bool {
        fatalError("Subclasses must override isRedundant(existing:)")
    }
}
