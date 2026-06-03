import Foundation

/// Easing functions for animation interpolation.
///
/// Each case represents a different easing curve. Use the `interpolate(_:)` method
/// to apply the easing function to a normalized value in the range `0...1`.
enum Easing: Int, CaseIterable {

    case none
    case linear
    case `in`
    case inQuad
    case out
    case outQuad
    case inOutQuad
    case inCubic
    case outCubic
    case inOutCubic
    case inQuart
    case outQuart
    case inOutQuart
    case inQuint
    case outQuint
    case inOutQuint
    case inSine
    case outSine
    case inOutSine
    case inExpo
    case outExpo
    case inOutExpo
    case inCirc
    case outCirc
    case inOutCirc
    case inElastic
    case outElastic
    case outElasticHalf
    case outElasticQuarter
    case inOutElastic
    case inBack
    case outBack
    case inOutBack
    case inBounce
    case outBounce
    case inOutBounce
    case outPow10

    /// Applies this easing function to the given value.
    ///
    /// - Parameter value: A normalized input value, typically in the range `0...1`.
    /// - Returns: The eased output value.
    func interpolate(_ value: Float) -> Float {
        var n = value

        switch self {
        case .none, .linear:
            return n

        case .`in`, .inQuad:
            return n * n

        case .out, .outQuad:
            return n * (2 - n)

        case .inOutQuad:
            if n < 0.5 {
                return n * n * 2
            } else {
                n -= 1
                return n * n * (-2) + 1
            }

        case .inCubic:
            return n * n * n

        case .outCubic:
            n -= 1
            return n * n * n + 1

        case .inOutCubic:
            if n < 0.5 {
                return n * n * n * 4
            } else {
                n -= 1
                return n * n * n * 4 + 1
            }

        case .inQuart:
            return n * n * n * n

        case .outQuart:
            n -= 1
            return 1 - n * n * n * n

        case .inOutQuart:
            if n < 0.5 {
                return n * n * n * n * 8
            } else {
                n -= 1
                return n * n * n * n * (-8) + 1
            }

        case .inQuint:
            return n * n * n * n * n

        case .outQuint:
            n -= 1
            return n * n * n * n * n + 1

        case .inOutQuint:
            if n < 0.5 {
                return n * n * n * n * n * 16
            } else {
                n -= 1
                return n * n * n * n * n * 16 + 1
            }

        case .inSine:
            return 1 - cos(n * Float.pi / 2)

        case .outSine:
            return sin(n * Float.pi / 2)

        case .inOutSine:
            return 0.5 - 0.5 * cos(Float.pi * n)

        case .inExpo:
            return powf(2, 10 * (n - 1))

        case .outExpo:
            return -powf(2, -10 * n) + 1

        case .inOutExpo:
            if n < 0.5 {
                return 0.5 * powf(2, 20 * n - 10)
            } else {
                return 1 - 0.5 * powf(2, -20 * n + 10)
            }

        case .inCirc:
            return 1 - sqrtf(1 - n * n)

        case .outCirc:
            n -= 1
            return sqrtf(1 - n * n)

        case .inOutCirc:
            n *= 2
            if n < 1 {
                return 0.5 - 0.5 * sqrtf(1 - n * n)
            } else {
                n -= 2
                return 0.5 * sqrtf(1 - n * n) + 0.5
            }

        case .inElastic:
            return -(powf(2, -10 + 10 * n)) * sinf((1 - 0.3 / 4 - n) * (2 * Float.pi / 0.3))

        case .outElastic:
            return powf(2, -10 * n) * sinf((n - 0.3 / 4) * (2 * Float.pi / 0.3)) + 1

        case .outElasticHalf:
            return powf(2, -10 * n) * sinf((0.5 * n - 0.3 / 4) * (2 * Float.pi / 0.3)) + 1

        case .outElasticQuarter:
            return powf(2, -10 * n) * sinf((0.25 * n - 0.3 / 4) * (2 * Float.pi / 0.3)) + 1

        case .inOutElastic:
            n *= 2
            if n < 1 {
                return -0.5 * powf(2, -10 + 10 * n) * sinf((1 - 0.3 / 4 - n) * (2 * Float.pi / 0.3))
            } else {
                n -= 1
                return 0.5 * powf(2, -10 * n) * sinf((n - 0.3 / 4) * (2 * Float.pi / 0.3)) + 1
            }

        case .inBack:
            let s: Float = 1.70158
            return n * n * ((s + 1) * n - s)

        case .outBack:
            n -= 1
            let s: Float = 1.70158
            return n * n * ((s + 1) * n + s) + 1

        case .inOutBack:
            n *= 2
            let s: Float = 1.70158 * 1.525
            if n < 1 {
                return 0.5 * (n * n * ((s + 1) * n - s))
            } else {
                n -= 2
                return 0.5 * (n * n * ((s + 1) * n + s) + 2)
            }

        case .inBounce:
            return 1 - Easing.outBounce.interpolate(1 - n)

        case .outBounce:
            if n < 1 / 2.75 {
                return 7.5625 * n * n
            } else if n < 2 / 2.75 {
                n -= 1.5 / 2.75
                return 7.5625 * n * n + 0.75
            } else if n < 2.5 / 2.75 {
                n -= 2.25 / 2.75
                return 7.5625 * n * n + 0.9375
            } else {
                n -= 2.625 / 2.75
                return 7.5625 * n * n + 0.984375
            }

        case .inOutBounce:
            if n < 0.5 {
                return 0.5 - 0.5 * Easing.outBounce.interpolate(1 - 2 * n)
            } else {
                return Easing.outBounce.interpolate(2 * n - 1) * 0.5 + 0.5
            }

        case .outPow10:
            return (n - 1) * powf(n, 10) + 1
        }
    }
}
