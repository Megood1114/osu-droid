import Foundation

/// A parser for parsing a specific beatmap section.
class BeatmapSectionParser {
    
    /// Parses a line.
    ///
    /// - Parameters:
    ///   - beatmap: The beatmap to fill.
    ///   - line: The line to parse.
    /// - Throws: When the performed operation for the line is not supported.
    func parse(beatmap: Beatmap, line: String) throws {
        preconditionFailure("This method must be overridden")
    }
    
    /// Attempts to parse a string into an integer.
    ///
    /// - Parameters:
    ///   - str: The string to parse.
    ///   - parseLimit: The threshold of the integer being parsed.
    /// - Returns: The parsed integer.
    /// - Throws: When the resulting value is invalid, or it is out of the parse limit bound.
    func parseInt(_ str: String, parseLimit: Int = BeatmapSectionParser.MAX_PARSE_LIMIT) throws -> Int {
        guard let value = Int(str) else {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not a number: \(str)"])
        }
        
        if value < -parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too low"])
        }
        
        if value > parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too high"])
        }
        
        return value
    }
    
    /// Attempts to parse a string into a float.
    ///
    /// - Parameters:
    ///   - str: The string to parse.
    ///   - parseLimit: The threshold of the float being parsed.
    ///   - allowNaN: Whether to allow NaN.
    /// - Returns: The parsed float.
    /// - Throws: When the resulting value is invalid or out of bounds.
    func parseFloat(_ str: String, parseLimit: Float = Float(BeatmapSectionParser.MAX_PARSE_LIMIT), allowNaN: Bool = false) throws -> Float {
        guard let value = Float(str) else {
            if allowNaN && str.lowercased() == "nan" {
                return Float.nan
            }
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not a number: \(str)"])
        }
        
        if value < -parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too low"])
        }
        
        if value > parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too high"])
        }
        
        if !allowNaN && value.isNaN {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not a number"])
        }
        
        return value
    }
    
    /// Attempts to parse a string into a double.
    ///
    /// - Parameters:
    ///   - str: The string to parse.
    ///   - parseLimit: The threshold of the double being parsed.
    ///   - allowNaN: Whether to allow NaN.
    /// - Returns: The parsed double.
    /// - Throws: When the resulting value is invalid or out of bounds.
    func parseDouble(_ str: String, parseLimit: Double = Double(BeatmapSectionParser.MAX_PARSE_LIMIT), allowNaN: Bool = false) throws -> Double {
        guard let value = Double(str) else {
            if allowNaN && str.lowercased() == "nan" {
                return Double.nan
            }
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not a number: \(str)"])
        }
        
        if value < -parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too low"])
        }
        
        if value > parseLimit {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Value is too high"])
        }
        
        if !allowNaN && value.isNaN {
            throw NSError(domain: "BeatmapSectionParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not a number"])
        }
        
        return value
    }
    
    static let COMMA_PROPERTY_REGEX = ","
    static let COLON_PROPERTY_REGEX = ":"
    
    static let FIRST_LAZER_VERSION = 128
    static let MAX_PARSE_LIMIT = Int.max
}
