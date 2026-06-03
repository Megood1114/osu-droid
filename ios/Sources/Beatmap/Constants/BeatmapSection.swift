/// Available sections in a `.osu` beatmap file.
enum BeatmapSection: Int, CaseIterable {
    case general
    case editor
    case metadata
    case difficulty
    case events
    case timingPoints
    case colors
    case hitObjects

    /// Converts a string section value from a beatmap file to its enum counterpart.
    ///
    /// - Parameter value: The value to convert.
    /// - Returns: The enum representing the value, or `nil` if unknown.
    static func parse(_ value: String?) -> BeatmapSection? {
        switch value {
        case "General": return .general
        case "Editor": return .editor
        case "Metadata": return .metadata
        case "Difficulty": return .difficulty
        case "Events": return .events
        case "TimingPoints": return .timingPoints
        case "Colours": return .colors
        case "HitObjects": return .hitObjects
        default: return nil
        }
    }
}
