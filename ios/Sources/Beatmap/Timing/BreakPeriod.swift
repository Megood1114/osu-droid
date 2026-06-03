/// Represents a break period.
struct BreakPeriod: Equatable, Hashable {
    /// The time at which the break period starts, in milliseconds.
    let startTime: Float

    /// The time at which the break period ends, in milliseconds.
    let endTime: Float

    /// The duration of this break period, in milliseconds.
    var duration: Float {
        endTime - startTime
    }
}
