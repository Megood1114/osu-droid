import Foundation

/// A parser for parsing a beatmap's events section.
class BeatmapEventsParser: BeatmapSectionParser {
    static let splitRegex = try! NSRegularExpression(pattern: "\\s*,\\s*")
    
    override func parse(beatmap: Beatmap, line: String) throws {
        let nsLine = line as NSString
        let matches = BeatmapEventsParser.splitRegex.matches(in: line, range: NSRange(location: 0, length: nsLine.length))
        
        var it = [String]()
        var lastRangeEnd = 0
        
        for match in matches {
            let range = match.range
            it.append(nsLine.substring(with: NSRange(location: lastRangeEnd, length: range.location - lastRangeEnd)))
            lastRangeEnd = range.location + range.length
        }
        it.append(nsLine.substring(from: lastRangeEnd))
        
        // Emulate dropLastWhile { it.isEmpty() }
        var dropCount = 0
        for item in it.reversed() {
            if item.isEmpty {
                dropCount += 1
            } else {
                break
            }
        }
        it = Array(it.dropLast(dropCount))
        
        if it.count >= 3 {
            if line.hasPrefix("0,0") {
                beatmap.events.backgroundFilename = cleanFilename(it[2])
            }
            
            if line.hasPrefix("2") || line.hasPrefix("Break") {
                let start = beatmap.getOffsetTime(time: Double(try parseInt(it[1])))
                let end = max(start, beatmap.getOffsetTime(time: Double(try parseInt(it[2]))))
                
                beatmap.events.breaks.append(BreakPeriod(startTime: Float(start), endTime: Float(end)))
            }
            
            if line.hasPrefix("1") || line.hasPrefix("Video") {
                beatmap.events.videoStartTime = try parseInt(it[1])
                beatmap.events.videoFilename = cleanFilename(it[2])
            }
        }
        
        if it.count >= 5 && line.hasPrefix("3") {
            beatmap.events.backgroundColor = Color4(
                r: try parseInt(it[2]),
                g: try parseInt(it[3]),
                b: try parseInt(it[4])
            )
        }
    }
    
    private func cleanFilename(_ path: String) -> String {
        return path.replacingOccurrences(of: "\\\\", with: "\\").trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
