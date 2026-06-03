import Foundation

/// Types of slider paths.
enum SliderPathType {
    case catmull
    case bezier
    case linear
    case perfectCurve

    /// Parses a character into a `SliderPathType`.
    ///
    /// - Parameter value: The character to parse.
    /// - Returns: The corresponding `SliderPathType`.
    static func parse(_ value: Character) -> SliderPathType {
        switch value {
        case "C": return .catmull
        case "L": return .linear
        case "P": return .perfectCurve
        default: return .bezier
        }
    }
}
