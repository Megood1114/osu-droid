import Foundation

/// A parser for parsing a beatmap's timing points section.
class BeatmapControlPointsParser: BeatmapSectionParser {
    override func parse(beatmap: Beatmap, line: String) throws {
        var it = line.components(separatedBy: BeatmapSectionParser.COMMA_PROPERTY_REGEX)
        
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
        
        if it.count < 2 {
            throw NSError(domain: "BeatmapControlPointsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed timing point"])
        }
        
        let time = beatmap.getOffsetTime(time: try parseDouble(it[0].trimmingCharacters(in: .whitespacesAndNewlines)))
        
        // msPerBeat is allowed to be NaN to handle an edge case in which some
        // beatmaps use NaN slider velocity to disable slider tick generation.
        let msPerBeat = try parseDouble(it[1].trimmingCharacters(in: .whitespacesAndNewlines), allowNaN: true)
        
        let timeSignature = it.count > 2 ? try parseInt(it[2]) : 4
        if timeSignature < 1 {
            throw NSError(domain: "BeatmapControlPointsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "The numerator of a time signature must be positive"])
        }
        
        var sampleSet = it.count > 3 ? SampleBank.parse(try parseInt(it[3])) : beatmap.general.sampleBank
        let customSampleBank = it.count > 4 ? try parseInt(it[4]) : 0
        let sampleVolume = it.count > 5 ? try parseInt(it[5]) : beatmap.general.sampleVolume
        
        let timingChange = it.count > 6 ? (it[6] == "1") : true
        let isKiai = it.count > 7 ? ((try parseInt(it[7])) & 1 != 0) : false
        
        if sampleSet == .none {
            sampleSet = .normal
        }
        
        if timingChange {
            if msPerBeat.isNaN {
                throw NSError(domain: "BeatmapControlPointsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Beat length cannot be NaN in a timing control point"])
            }
            beatmap.controlPoints.timing.add(TimingControlPoint(time: time, msPerBeat: msPerBeat, timeSignature: timeSignature))
        }
        
        let speedMultiplier: Double = msPerBeat < 0 ? min(max(100.0 / -msPerBeat, 0.1), 10.0) : 1.0
        
        beatmap.controlPoints.difficulty.add(
            DifficultyControlPoint(
                time: time,
                speedMultiplier: speedMultiplier,
                generateTicks: !msPerBeat.isNaN
            )
        )
        
        beatmap.controlPoints.effect.add(EffectControlPoint(time: time, isKiai: isKiai))
        beatmap.controlPoints.sample.add(SampleControlPoint(time: time, sampleBank: sampleSet, sampleVolume: sampleVolume, customSampleBank: customSampleBank))
    }
}
