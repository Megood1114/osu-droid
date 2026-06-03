import Foundation

/// Precision utilities.
enum Precision {
    /// The default epsilon for all `Float` values.
    static let floatEpsilon: Float = 1e-3

    /// The default epsilon for all `Double` values.
    static let doubleEpsilon: Double = 1e-7

    /// Checks if a `Float` is definitely greater than another `Float` with a given tolerance.
    ///
    /// - Parameters:
    ///   - value1: The first `Float`.
    ///   - value2: The second `Float`.
    ///   - acceptableDifference: The acceptable difference. Defaults to ``floatEpsilon``.
    /// - Returns: Whether `value1` is definitely greater than `value2`.
    static func definitelyBigger(_ value1: Float, _ value2: Float, acceptableDifference: Float = floatEpsilon) -> Bool {
        value1 - acceptableDifference > value2
    }

    /// Checks if a `Double` is definitely greater than another `Double` with a given tolerance.
    ///
    /// - Parameters:
    ///   - value1: The first `Double`.
    ///   - value2: The second `Double`.
    ///   - acceptableDifference: The acceptable difference. Defaults to ``doubleEpsilon``.
    /// - Returns: Whether `value1` is definitely greater than `value2`.
    static func definitelyBigger(_ value1: Double, _ value2: Double, acceptableDifference: Double = doubleEpsilon) -> Bool {
        value1 - acceptableDifference > value2
    }

    /// Checks if two numbers are equal with a given tolerance.
    ///
    /// - Parameters:
    ///   - value1: The first number.
    ///   - value2: The second number.
    ///   - acceptableDifference: The acceptable difference as threshold.
    /// - Returns: Whether the two values are almost equal.
    static func almostEquals(_ value1: Float, _ value2: Float, acceptableDifference: Float = floatEpsilon) -> Bool {
        abs(value1 - value2) <= acceptableDifference
    }

    /// Checks if two numbers are equal with a given tolerance.
    ///
    /// - Parameters:
    ///   - value1: The first number.
    ///   - value2: The second number.
    ///   - acceptableDifference: The acceptable difference as threshold.
    /// - Returns: Whether the two values are almost equal.
    static func almostEquals(_ value1: Double, _ value2: Double, acceptableDifference: Double = doubleEpsilon) -> Bool {
        abs(value1 - value2) <= acceptableDifference
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
