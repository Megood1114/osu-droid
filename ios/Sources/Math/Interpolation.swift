import Foundation

/// Holds interpolation methods for numbers.
enum Interpolation {
    /// Performs a linear interpolation.
    ///
    /// - Parameters:
    ///   - start: The starting point of the interpolation.
    ///   - end: The final point of the interpolation.
    ///   - amount: The interpolation multiplier.
    /// - Returns: The interpolated value.
    static func linear(start: Double, end: Double, amount: Double) -> Double {
        start + (end - start) * amount
    }

    /// Performs a linear interpolation.
    ///
    /// - Parameters:
    ///   - start: The starting point of the interpolation.
    ///   - end: The final point of the interpolation.
    ///   - amount: The interpolation multiplier.
    /// - Returns: The interpolated value.
    static func linear(start: Float, end: Float, amount: Float) -> Float {
        start + (end - start) * amount
    }

    /// Performs a linear interpolation.
    ///
    /// - Parameters:
    ///   - start: The starting point of the interpolation.
    ///   - end: The final point of the interpolation.
    ///   - amount: The interpolation multiplier.
    /// - Returns: The interpolated value.
    static func linear(start: Vector2, end: Vector2, amount: Float) -> Vector2 {
        Vector2(
            x: linear(start: start.x, end: end.x, amount: amount),
            y: linear(start: start.y, end: end.y, amount: amount)
        )
    }

    /// Calculates the reverse [linear interpolation](https://en.wikipedia.org/wiki/Linear_interpolation)
    /// function at `x`.
    ///
    /// - Parameters:
    ///   - x: The value to calculate the function for.
    ///   - start: The `x` value at which the function returns 0.
    ///   - end: The `x` value at which the function returns 1.
    /// - Returns: The output of the reverse linear interpolation function calculated at `x`.
    static func reverseLinear(x: Double, start: Double, end: Double) -> Double {
        min(1.0, max(0.0, (x - start) / (end - start)))
    }

    /// Interpolates between `start` and `end` using a given `base` and `exponent`.
    ///
    /// - Parameters:
    ///   - start: The starting point of the interpolation.
    ///   - end: The final point of the interpolation.
    ///   - base: The base of the exponential. The valid range is `[0, 1]`, where smaller values mean that `end` is
    ///     achieved more quickly, and values closer to 1 results in slow convergence to `end`.
    ///   - exponent: The exponent of the exponential. An exponent of 0 results in `start`, whereas larger
    ///     exponents make the result converge to `end`.
    /// - Returns: The interpolated value.
    static func damp(start: Float, end: Float, base: Float, exponent: Float) -> Float {
        if base < 0 || base > 1 {
            fatalError("Base must be in the range [0, 1].")
        }

        return linear(start: start, end: end, amount: 1 - pow(base, exponent))
    }

    /// Interpolates `current` towards `target` based on `elapsedTime`. If `current` is updated every frame using this
    /// function, the result is approximately frame-rate independent.
    ///
    /// Because floating-point errors can accumulate over a long time, this function should not be used for things
    /// requiring accurate values.
    ///
    /// - Parameters:
    ///   - current: The current value.
    ///   - target: The target value.
    ///   - halfTime: The time taken for the value to reach the middle value of `current` and `target`.
    ///   - elapsedTime: The elapsed time of the current frame.
    /// - Returns: The interpolated value.
    static func dampContinuously(current: Float, target: Float, halfTime: Float, elapsedTime: Float) -> Float {
        damp(start: current, end: target, base: 0.5, exponent: elapsedTime / halfTime)
    }
}
