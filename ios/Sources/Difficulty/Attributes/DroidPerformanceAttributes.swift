import Foundation

/// A structure containing the osu!droid performance values of a score.
public class DroidPerformanceAttributes: PerformanceAttributes {
    /// The tap performance value.
    public var tap: Double = 0.0

    /// The reading performance value.
    public var reading: Double = 0.0

    /// The tap penalty used to penalize the tap performance value.
    public var tapPenalty: Double = 1.0

    /// The estimated deviation of the score.
    public var deviation: Double = 0.0

    /// The estimated tap deviation of the score.
    public var tapDeviation: Double = 0.0

    /// The penalty used to penalize the aim performance value.
    public var aimSliderCheesePenalty: Double = 1.0

    /// The penalty used to penalize the flashlight performance value.
    public var flashlightSliderCheesePenalty: Double = 1.0
}
