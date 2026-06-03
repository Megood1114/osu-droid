import Foundation

/// Represents available sample banks.
enum SampleBank {
    case none
    case normal
    case soft
    case drum

    /// The prefix of audio files representing this sample bank.
    var prefix: String {
        switch self {
        case .none: return ""
        case .normal: return "normal"
        case .soft: return "soft"
        case .drum: return "drum"
        }
    }

    /// Converts an integer value to its sample bank counterpart.
    ///
    /// - Parameter value: The value to convert.
    /// - Returns: The sample bank counterpart of the given value.
    static func parse(_ value: Int) -> SampleBank {
        switch value {
        case 1: return .normal
        case 2: return .soft
        case 3: return .drum
        default: return .none
        }
    }

    /// Converts a string value to its sample bank counterpart.
    ///
    /// - Parameter value: The value to convert.
    /// - Returns: The sample bank counterpart of the given value.
    static func parse(_ value: String?) -> SampleBank {
        switch value {
        case "Normal": return .normal
        case "Soft": return .soft
        case "Drum": return .drum
        default: return .none
        }
    }
}
