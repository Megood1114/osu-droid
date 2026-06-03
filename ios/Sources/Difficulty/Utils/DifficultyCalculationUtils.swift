import Foundation

/// Utilities for difficulty calculation.
public enum DifficultyCalculationUtils {
    /// Converts a BPM value to milliseconds.
    ///
    /// - Parameters:
    ///   - bpm: The BPM value.
    ///   - delimiter: The denominator of the time signature. Defaults to 4.
    /// - Returns: The BPM value in milliseconds.
    public static func bpmToMilliseconds(bpm: Double, delimiter: Int = 4) -> Double {
        return 60000.0 / bpm / Double(delimiter)
    }

    /// Converts milliseconds to a BPM value.
    ///
    /// - Parameters:
    ///   - milliseconds: The milliseconds value.
    ///   - delimiter: The denominator of the time signature. Defaults to 4.
    /// - Returns: The milliseconds value in BPM.
    public static func millisecondsToBPM(milliseconds: Double, delimiter: Int = 4) -> Double {
        return 60000.0 / (milliseconds * Double(delimiter))
    }

    /// Calculates an S-shaped logistic function with exponent at `exponent`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent to calculate the function for.
    ///   - maxValue: Maximum value returnable by the function.
    /// - Returns: The output of the logistic function calculated at `exponent`.
    public static func logistic(exponent: Double, maxValue: Double = 1.0) -> Double {
        return maxValue / (1.0 + exp(exponent))
    }

    /// Calculates an S-shaped logistic function with offset at `x`.
    ///
    /// - Parameters:
    ///   - x: The value to calculate the function for.
    ///   - midpointOffset: How much the function midpoint is offset from zero `x`.
    ///   - multiplier: The growth rate of the function.
    ///   - maxValue: Maximum value returnable by the function.
    /// - Returns: The output of the logistic function calculated at `x`.
    public static func logistic(x: Double, midpointOffset: Double, multiplier: Double, maxValue: Double = 1.0) -> Double {
        return maxValue / (1.0 + exp(-multiplier * (x - midpointOffset)))
    }

    /// Calculates the smoothstep function at `x`.
    ///
    /// - Parameters:
    ///   - x: The value to calculate the function for.
    ///   - start: The `x` value at which the function returns 0.
    ///   - end: The `x` value at which the function returns 1.
    /// - Returns: The output of the smoothstep function calculated at `x`.
    public static func smoothstep(x: Double, start: Double, end: Double) -> Double {
        let t = Interpolation.reverseLinear(x: x, start: start, end: end)
        return t * t * (3.0 - 2.0 * t)
    }

    /// Calculates the smootherstep function at `x`.
    ///
    /// - Parameters:
    ///   - x: The value to calculate the function for.
    ///   - start: The `x` value at which the function returns 0.
    ///   - end: The `x` value at which the function returns 1.
    /// - Returns: The output of the smootherstep function calculated at `x`.
    public static func smootherstep(x: Double, start: Double, end: Double) -> Double {
        let t = Interpolation.reverseLinear(x: x, start: start, end: end)
        return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
    }

    /// Calculates a smoothstep bell curve function that returns 1 for
    /// when `x` is equal to `mean`, and smoothly reducing its value to 0 over `width`.
    ///
    /// - Parameters:
    ///   - x: The value to calculate the function for.
    ///   - mean: The value of `x` for which the return value will be the highest (=1).
    ///   - width: The range `[mean - width, mean + width]` where the function will change values.
    /// - Returns: The output of the smoothstep bell curve function calculated at `x`.
    public static func smoothstepBellCurve(x: Double, mean: Double = 0.5, width: Double = 0.5) -> Double {
        var xAdj = x - mean
        xAdj = if xAdj > 0 { width - xAdj } else { width + xAdj }

        return smoothstep(x: xAdj, start: 0.0, end: width)
    }
}
