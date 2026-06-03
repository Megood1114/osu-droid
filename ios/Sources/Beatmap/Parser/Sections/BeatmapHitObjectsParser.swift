import Foundation

/// Represents a hit object specific sample bank.
private struct SampleBankInfo {
    var filename: String = ""
    var normal: SampleBank = .none
    var add: SampleBank = .none
    var volume: Int = 0
    var customSampleBank: Int = 0
}

/// Hit sound types that are provided by the game.
private enum HitSoundType: Int {
    case none = 0
    case normal = 1
    case whistle = 2 // 1 << 1
    case finish = 4 // 1 << 2
    case clap = 8 // 1 << 3
    
    var bit: Int { return rawValue }
}

private func containsType(_ value: Int, _ type: HitSoundType) -> Bool {
    return (value & type.bit) != 0
}

/// A parser for parsing a beatmap's hit objects section.
class BeatmapHitObjectsParser: BeatmapSectionParser {
    private static let pipePropertyRegex = "[|]"
    
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
        
        if it.count < 4 {
            throw NSError(domain: "BeatmapHitObjectsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed hit object"])
        }
        
        let time = beatmap.getOffsetTime(time: try parseDouble(it[2]))
        let type = try parseInt(it[3])
        
        var tempType = type
        
        let comboOffset = (tempType & HitObjectType.comboColorOffset.rawValue) >> 4
        tempType = tempType & ~HitObjectType.comboColorOffset.rawValue
        
        let isNewCombo = (tempType & HitObjectType.newCombo.rawValue) != 0
        
        let position = try parseCoordinates(formatVersion: beatmap.formatVersion, x: it[0], y: it[1])
        
        let soundType = try parseInt(it[4])
        var bankInfo = SampleBankInfo()
        
        let objType = HitObjectType(rawValue: type % 16)
        
        let obj: HitObject
        switch objType {
        case .normal, .normalNewCombo:
            obj = try createCircle(pars: it, beatmap: beatmap, time: time, position: position, isNewCombo: beatmap.hitObjects.objects.isEmpty || isNewCombo, comboOffset: comboOffset, bankInfo: &bankInfo)
        case .slider, .sliderNewCombo:
            obj = try createSlider(pars: it, beatmap: beatmap, time: time, startPosition: position, isNewCombo: beatmap.hitObjects.objects.isEmpty || isNewCombo, comboOffset: comboOffset, soundType: soundType, bankInfo: &bankInfo)
        case .spinner:
            obj = try createSpinner(pars: it, beatmap: beatmap, time: time, isNewCombo: isNewCombo, bankInfo: &bankInfo)
        default:
            throw NSError(domain: "BeatmapHitObjectsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed hit object"])
        }
        
        obj.samples.append(contentsOf: convertSoundType(soundType: soundType, bankInfo: bankInfo))
        beatmap.hitObjects.add(obj)
    }
    
    private func createCircle(pars: [String], beatmap: Beatmap, time: Double, position: Vector2, isNewCombo: Bool, comboOffset: Int, bankInfo: inout SampleBankInfo) throws -> HitCircle {
        let isFirstOrAfterSpinner = beatmap.hitObjects.objects.isEmpty || beatmap.hitObjects.objects.last is Spinner || isNewCombo
        let circle = HitCircle(startTime: time, position: position, isNewCombo: isFirstOrAfterSpinner, comboOffset: comboOffset)
        
        if pars.count > 5 {
            try readCustomSampleBanks(bankInfo: &bankInfo, str: pars[5])
        }
        return circle
    }
    
    private func createSlider(pars: [String], beatmap: Beatmap, time: Double, startPosition: Vector2, isNewCombo: Bool, comboOffset: Int, soundType: Int, bankInfo: inout SampleBankInfo) throws -> Slider {
        if pars.count < 8 {
            throw NSError(domain: "BeatmapHitObjectsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Malformed slider"])
        }
        
        var repeatCount = try parseInt(pars[6])
        let rawLength = max(0.0, try parseDouble(pars[7]))
        
        if repeatCount > 9000 {
            throw NSError(domain: "BeatmapHitObjectsParser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Repeat count is way too high"])
        }
        
        repeatCount = max(0, repeatCount - 1)
        
        var curvePointsData = pars[5].components(separatedBy: "|")
        var dropCount = 0
        for item in curvePointsData.reversed() {
            if item.isEmpty {
                dropCount += 1
            } else {
                break
            }
        }
        curvePointsData = Array(curvePointsData.dropLast(dropCount))
        
        var sliderType = SliderPathType.parse(curvePointsData[0].first ?? " ")
        var curvePoints = [Vector2(x: 0, y: 0)]
        
        for i in 1..<curvePointsData.count {
            var it = curvePointsData[i].components(separatedBy: BeatmapSectionParser.COLON_PROPERTY_REGEX)
            var dropCount2 = 0
            for item in it.reversed() {
                if item.isEmpty {
                    dropCount2 += 1
                } else {
                    break
                }
            }
            it = Array(it.dropLast(dropCount2))
            
            let curvePointPosition = try parseCoordinates(formatVersion: beatmap.formatVersion, x: it[0], y: it[1])
            curvePoints.append(curvePointPosition - startPosition)
        }
        
        if sliderType == .catmull && curvePoints.count >= 2 && curvePoints[0] == curvePoints[1] {
            curvePoints.removeFirst()
        }
        
        if sliderType == .perfectCurve {
            if beatmap.formatVersion < BeatmapSectionParser.FIRST_LAZER_VERSION {
                if curvePoints.count != 3 {
                    sliderType = .bezier
                } else {
                    let colinear = abs((curvePoints[1].y - curvePoints[0].y) * (curvePoints[2].x - curvePoints[0].x) - (curvePoints[1].x - curvePoints[0].x) * (curvePoints[2].y - curvePoints[0].y))
                    if colinear < 1e-5 { // almostEquals 0f
                        sliderType = .linear
                    }
                }
            } else if curvePoints.count > 3 {
                sliderType = .bezier
            }
        }
        
        let path = SliderPath(pathType: sliderType, controlPoints: curvePoints, expectedDistance: rawLength)
        
        if pars.count > 10 {
            try readCustomSampleBanks(bankInfo: &bankInfo, str: pars[10], banksOnly: true)
        }
        
        let nodes = repeatCount + 2
        var nodeBankInfo = Array(repeating: bankInfo, count: nodes)
        
        if pars.count > 9 {
            let sets = pars[9].components(separatedBy: "|")
            for i in 0..<min(sets.count, nodes) {
                try readCustomSampleBanks(bankInfo: &nodeBankInfo[i], str: sets[i])
            }
        }
        
        var nodeSoundTypes = Array(repeating: soundType, count: nodes)
        if pars.count > 8 {
            let adds = pars[8].components(separatedBy: "|")
            for i in 0..<min(adds.count, nodes) {
                nodeSoundTypes[i] = try parseInt(adds[i])
            }
        }
        
        var nodeSamples = [[HitSampleInfo]]()
        for i in 0..<nodes {
            nodeSamples.append(convertSoundType(soundType: nodeSoundTypes[i], bankInfo: nodeBankInfo[i]))
        }
        
        let difficultyControlPoint = beatmap.controlPoints.difficulty.controlPointAt(time)
        
        let isFirstOrAfterSpinner = beatmap.hitObjects.objects.isEmpty || beatmap.hitObjects.objects.last is Spinner || isNewCombo
        let slider = Slider(startTime: time, position: startPosition, repeatCount: repeatCount, path: path, isNewCombo: isFirstOrAfterSpinner, comboOffset: comboOffset, nodeSamples: nodeSamples)
        
        if !difficultyControlPoint.generateTicks {
            slider.tickDistanceMultiplier = Double.infinity
        } else if beatmap.formatVersion < 8 {
            slider.tickDistanceMultiplier = 1.0 / difficultyControlPoint.speedMultiplier
        } else {
            slider.tickDistanceMultiplier = 1.0
        }
        
        return slider
    }
    
    private func createSpinner(pars: [String], beatmap: Beatmap, time: Double, isNewCombo: Bool, bankInfo: inout SampleBankInfo) throws -> Spinner {
        let endTime = beatmap.getOffsetTime(time: Double(try parseInt(pars[5])))
        let spinner = Spinner(startTime: time, endTime: endTime, isNewCombo: isNewCombo)
        if pars.count > 6 {
            try readCustomSampleBanks(bankInfo: &bankInfo, str: pars[6])
        }
        return spinner
    }
    
    private func convertSoundType(soundType: Int, bankInfo: SampleBankInfo) -> [HitSampleInfo] {
        var samples = [HitSampleInfo]()
        
        if !bankInfo.filename.isEmpty {
            samples.append(FileHitSampleInfo(filename: bankInfo.filename, volume: bankInfo.volume))
        } else {
            let isLayered = soundType != HitSoundType.none.bit && !containsType(soundType, .normal)
            samples.append(BankHitSampleInfo(name: BankHitSampleInfo.hitNormal, bank: bankInfo.normal, customSampleBank: bankInfo.customSampleBank, volume: bankInfo.volume, isLayered: isLayered))
        }
        
        func addBankSample(name: String) {
            samples.append(BankHitSampleInfo(name: name, bank: bankInfo.add, customSampleBank: bankInfo.customSampleBank, volume: bankInfo.volume))
        }
        
        if containsType(soundType, .finish) {
            addBankSample(name: BankHitSampleInfo.hitFinish)
        }
        
        if containsType(soundType, .whistle) {
            addBankSample(name: BankHitSampleInfo.hitWhistle)
        }
        
        if containsType(soundType, .clap) {
            addBankSample(name: BankHitSampleInfo.hitClap)
        }
        
        return samples
    }
    
    private func readCustomSampleBanks(bankInfo: inout SampleBankInfo, str: String, banksOnly: Bool = false) throws {
        if str.isEmpty { return }
        
        let s = str.components(separatedBy: BeatmapSectionParser.COLON_PROPERTY_REGEX)
        
        if let b0 = Int(s[0]) {
            bankInfo.normal = SampleBank.parse(b0)
        }
        
        if s.count > 1, let b1 = Int(s[1]) {
            let addBank = SampleBank.parse(b1)
            bankInfo.add = addBank != .none ? addBank : bankInfo.normal
        } else {
            bankInfo.add = bankInfo.normal
        }
        
        if banksOnly { return }
        
        if s.count > 2, let c = Int(s[2]) {
            bankInfo.customSampleBank = c
        }
        
        if s.count > 3, let v = Int(s[3]) {
            bankInfo.volume = max(0, v)
        }
        
        if s.count > 4 {
            bankInfo.filename = s[4]
        }
    }
    
    private func parseCoordinates(formatVersion: Int, x: String, y: String) throws -> Vector2 {
        if formatVersion >= BeatmapSectionParser.FIRST_LAZER_VERSION {
            return Vector2(x: try parseFloat(x), y: try parseFloat(y))
        } else {
            return Vector2(x: Float(try parseFloat(x).rounded(.towardZero)), y: Float(try parseFloat(y).rounded(.towardZero)))
        }
    }
}
