import Foundation

/// A structure containing the performance values of a score.
open class PerformanceAttributes {
    /// Calculated score performance points.
    public var total: Double = 0.0

    /// The aim performance value.
    public var aim: Double = 0.0

    /// The accuracy performance value.
    public var accuracy: Double = 0.0

    /// The flashlight performance value.
    public var flashlight: Double = 0.0

    /// The amount of misses including slider breaks.
    public var effectiveMissCount: Double = 0.0

    public init() {}
}
