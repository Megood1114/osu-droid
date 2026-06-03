import Foundation

/// A parser for parsing beatmap sections that store properties in a key-value pair.
class BeatmapKeyValueSectionParser: BeatmapSectionParser {
    
    /// Obtains the property of a line.
    ///
    /// For example, `ApproachRate:9` will be split into `["ApproachRate", "9"]`.
    ///
    /// - Parameters:
    ///   - line: The line.
    /// - Returns: A tuple containing the properties, or `nil` if the line is invalid.
    func splitProperty(line: String) -> (String, String)? {
        let s = line.components(separatedBy: BeatmapSectionParser.COLON_PROPERTY_REGEX)
        
        // Emulate Kotlin's dropLastWhile { it.isEmpty() }
        var dropCount = 0
        for item in s.reversed() {
            if item.isEmpty {
                dropCount += 1
            } else {
                break
            }
        }
        
        let filteredS = Array(s.dropLast(dropCount))
        
        if filteredS.isEmpty {
            return nil
        }
        
        let first = filteredS[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let second = filteredS.count > 1 ? filteredS.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines) : ""
        
        return (first, second)
    }
}
