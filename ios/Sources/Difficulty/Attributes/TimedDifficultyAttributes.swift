import Foundation

/// Wraps a `DifficultyAttributes` object and adds a time value for which the attribute is valid.
public class TimedDifficultyAttributes<TAttributes: DifficultyAttributes>: Comparable {
    /// The non-clock-adjusted time value at which the attributes take effect.
    public let time: Double

    /// The attributes.
    public let attributes: TAttributes

    public init(time: Double, attributes: TAttributes) {
        self.time = time
        self.attributes = attributes
    }

    public static func < (lhs: TimedDifficultyAttributes<TAttributes>, rhs: TimedDifficultyAttributes<TAttributes>) -> Bool {
        return lhs.time < rhs.time
    }

    public static func == (lhs: TimedDifficultyAttributes<TAttributes>, rhs: TimedDifficultyAttributes<TAttributes>) -> Bool {
        return lhs.time == rhs.time
    }
}
