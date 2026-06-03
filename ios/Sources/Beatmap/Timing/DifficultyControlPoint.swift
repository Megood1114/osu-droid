/// Represents a `ControlPoint` that changes speed multiplier.
class DifficultyControlPoint: ControlPoint {
    /// The slider speed multiplier of this `DifficultyControlPoint`.
    let speedMultiplier: Double

    /// Whether slider ticks should be generated at this `DifficultyControlPoint`.
    ///
    /// This exists for backwards compatibility with maps that abuse NaN slider velocity behavior on osu!stable (e.g. /b/2628991).
    let generateTicks: Bool

    /// Creates a new `DifficultyControlPoint`.
    ///
    /// - Parameters:
    ///   - time: The time at which this control point takes effect, in milliseconds.
    ///   - speedMultiplier: The slider speed multiplier.
    ///   - generateTicks: Whether slider ticks should be generated.
    init(time: Double, speedMultiplier: Double, generateTicks: Bool) {
        self.speedMultiplier = speedMultiplier
        self.generateTicks = generateTicks
        super.init(time: time)
    }

    override func isRedundant(existing: ControlPoint) -> Bool {
        guard let existing = existing as? DifficultyControlPoint else {
            return false
        }

        return speedMultiplier == existing.speedMultiplier &&
               generateTicks == existing.generateTicks
    }
}
