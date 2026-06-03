/// Represents the speed of the countdown before the first hit object.
enum BeatmapCountdown: Int, CaseIterable {
    case noCountdown = 0
    case normal = 1
    case half = 2
    case twice = 3

    /// The speed at which the beatmap countdown should be played.
    var speed: Float {
        switch self {
        case .noCountdown: return 0
        case .normal: return 1
        case .half: return 0.5
        case .twice: return 2
        }
    }

    /// Converts a string data from a beatmap file to its enum counterpart.
    ///
    /// - Parameter data: The data to convert.
    /// - Returns: The enum representing the data.
    static func parse(_ data: String?) -> BeatmapCountdown {
        switch data {
        case "0": return .noCountdown
        case "2": return .half
        case "3": return .twice
        default: return .normal
        }
    }
}
