import Foundation

/// A parser for parsing a beatmap's colors section.
class BeatmapColorParser: BeatmapKeyValueSectionParser {
    override func parse(beatmap: Beatmap, line: String) throws {
        guard let p = splitProperty(line: line) else {
            throw NSError(domain: "BeatmapColorParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed color property: \(line)"])
        }
        
        var s = p.1.components(separatedBy: BeatmapSectionParser.COMMA_PROPERTY_REGEX)
        
        // dropLastWhile { it.isEmpty() }
        var dropCount = 0
        for item in s.reversed() {
            if item.isEmpty {
                dropCount += 1
            } else {
                break
            }
        }
        s = Array(s.dropLast(dropCount))
        
        if s.count != 3 && s.count != 4 {
            throw NSError(domain: "BeatmapColorParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Color specified in incorrect format (should be R,G,B or R,G,B,A)"])
        }
        
        let color = Color4(
            r: try parseInt(s[0]),
            g: try parseInt(s[1]),
            b: try parseInt(s[2])
        )
        
        if p.0.hasPrefix("Combo") {
            let indexString = String(p.0.dropFirst(5))
            let index = Int(indexString) ?? (beatmap.colors.comboColors.count + 1)
            
            beatmap.colors.comboColors.append(ComboColor(index: index, color: color))
            beatmap.colors.comboColors.sort { $0.index < $1.index }
        }
        
        if p.0.hasPrefix("SliderBorder") {
            beatmap.colors.sliderBorderColor = color
        }
    }
}
