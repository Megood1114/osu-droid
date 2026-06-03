import Foundation

/// A parser for parsing a beatmap's metadata section.
class BeatmapMetadataParser: BeatmapKeyValueSectionParser {
    override func parse(beatmap: Beatmap, line: String) throws {
        guard let property = splitProperty(line: line) else {
            throw NSError(domain: "BeatmapMetadataParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed metadata property: \(line)"])
        }
        
        switch property.0 {
        case "Title":
            beatmap.metadata.title = property.1
        case "TitleUnicode":
            beatmap.metadata.titleUnicode = property.1
        case "Artist":
            beatmap.metadata.artist = property.1
        case "ArtistUnicode":
            beatmap.metadata.artistUnicode = property.1
        case "Creator":
            beatmap.metadata.creator = property.1
        case "Version":
            beatmap.metadata.version = property.1
        case "Source":
            beatmap.metadata.source = property.1
        case "Tags":
            beatmap.metadata.tags = property.1
        case "BeatmapID":
            beatmap.metadata.beatmapId = try parseInt(property.1)
        case "BeatmapSetID":
            beatmap.metadata.beatmapSetId = try parseInt(property.1)
        default:
            break
        }
    }
}
