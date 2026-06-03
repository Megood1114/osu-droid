import Foundation

/// A parser for parsing `.osu` files.
class BeatmapParser {
    
    /// The `.osu` file.
    private let file: URL
    
    /// The precomputed MD5 hash of the beatmap file, if available.
    ///
    /// This is used to avoid unnecessary MD5 calculations when parsing.
    private let precomputedMD5: String?
    
    /// - Parameters:
    ///   - file: The `.osu` file URL.
    ///   - precomputedMD5: The precomputed MD5 hash of the beatmap file.
    init(file: URL, precomputedMD5: String? = nil) {
        self.file = file
        self.precomputedMD5 = precomputedMD5
    }
    
    /// - Parameters:
    ///   - path: The path to the `.osu` file.
    ///   - precomputedMD5: The precomputed MD5 hash of the beatmap file.
    convenience init(path: String, precomputedMD5: String? = nil) {
        self.init(file: URL(fileURLWithPath: path), precomputedMD5: precomputedMD5)
    }
    
    /// Parses the `.osu` file.
    ///
    /// - Parameters:
    ///   - withHitObjects: Whether to parse hit objects. Setting this to `false` will improve parsing time significantly.
    ///   - mode: The `GameMode` to parse for. Defaults to `.standard`.
    /// - Returns: A `Beatmap` containing relevant information of the beatmap file.
    /// - Throws: `IOException` if an I/O error occurs, `NumberFormatException` if version cannot be determined, `IllegalArgumentException` if not osu!standard.
    func parse(withHitObjects: Bool, mode: GameMode = .standard) throws -> Beatmap {
        let content: String
        do {
            content = try String(contentsOf: file, encoding: .utf8)
        } catch {
            throw NSError(domain: "BeatmapParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to read file: \(error.localizedDescription)"])
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        // Check for format version first to avoid unnecessary MD5 calculation.
        let formatVersion = try getFormatVersion(lines: lines)
        
        var currentSection: BeatmapSection? = nil
        
        let beatmap = Beatmap(mode: mode)
        beatmap.md5 = precomputedMD5 ?? FileUtils.getMD5Checksum(file: file)
        beatmap.filePath = file.path
        beatmap.formatVersion = formatVersion
        
        for var line in lines {
            if beatmap.general.mode != 0 {
                throw NSError(domain: "BeatmapParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not an osu!standard beatmap"])
            }
            
            // Handle space comments
            if line.hasPrefix(" ") || line.hasPrefix("_") {
                continue
            }
            
            // Trim space
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Handle C++ style comments and empty lines
            if line.hasPrefix("//") || line.isEmpty {
                continue
            }
            
            // [SectionName]
            if line.hasPrefix("[") && line.hasSuffix("]") {
                let sectionName = String(line.dropFirst().dropLast())
                currentSection = BeatmapSection(rawValue: sectionName)
                
                // HitObjects are always in the last section
                if currentSection == .hitObjects && !withHitObjects {
                    break
                }
                continue
            }
            
            guard let section = currentSection else {
                continue
            }
            
            do {
                switch section {
                case .general:
                    try BeatmapGeneralParser().parse(beatmap: beatmap, line: line)
                case .metadata:
                    try BeatmapMetadataParser().parse(beatmap: beatmap, line: line)
                case .difficulty:
                    try BeatmapDifficultyParser().parse(beatmap: beatmap, line: line)
                case .events:
                    try BeatmapEventsParser().parse(beatmap: beatmap, line: line)
                case .timingPoints:
                    try BeatmapControlPointsParser().parse(beatmap: beatmap, line: line)
                case .colors:
                    try BeatmapColorParser().parse(beatmap: beatmap, line: line)
                case .hitObjects:
                    try BeatmapHitObjectsParser().parse(beatmap: beatmap, line: line)
                default:
                    continue
                }
            } catch {
                print("BeatmapParser.parse: Unable to parse line \(line): \(error)")
            }
        }
        
        let processor = BeatmapProcessor(beatmap: beatmap)
        processor.preProcess()
        
        for it in beatmap.hitObjects.objects {
            it.applyDefaults(controlPoints: beatmap.controlPoints, difficulty: beatmap.difficulty, mode: mode)
            it.applySamples(controlPoints: beatmap.controlPoints)
        }
        
        processor.postProcess()
        
        return beatmap
    }
    
    private func getFormatVersion(lines: [String]) throws -> Int {
        guard let head = lines.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw NSError(domain: "BeatmapParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty file"])
        }
        
        let pattern = "osu file format v(\\d+)"
        let regex = try NSRegularExpression(pattern: pattern)
        let nsHead = head as NSString
        let match = regex.firstMatch(in: head, range: NSRange(location: 0, length: nsHead.length))
        
        guard let range = match?.range(at: 1) else {
            throw NSError(domain: "BeatmapParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid format version"])
        }
        
        let versionStr = nsHead.substring(with: range)
        guard let version = Int(versionStr) else {
            throw NSError(domain: "BeatmapParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid format version"])
        }
        
        return version
    }
}
