import Foundation

// MARK: - HitSampleInfo

/// Represents a gameplay hit sample.
class HitSampleInfo {
    /// The sample volume.
    ///
    /// If this is 0, the underlying control point's volume should be used instead.
    let volume: Int

    /// All possible filenames that can be used as an audio source, returned in order of preference (highest first).
    var lookupNames: [String] {
        []
    }

    init(volume: Int = 0) {
        self.volume = volume
    }

    func copy(volume: Int? = nil) -> HitSampleInfo {
        HitSampleInfo(volume: volume ?? self.volume)
    }
}

// MARK: - BankHitSampleInfo

/// Represents a pre-determined gameplay hit sample that can be loaded from banks.
class BankHitSampleInfo: HitSampleInfo {

    static let hitWhistle = "hitwhistle"
    static let hitFinish = "hitfinish"
    static let hitNormal = "hitnormal"
    static let hitClap = "hitclap"

    /// The name of the sample.
    let name: String

    /// The `SampleBank` to load the sample from.
    let bank: SampleBank

    /// The index of this `BankHitSampleInfo`, if it uses custom samples.
    ///
    /// If this is 0, the underlying control point's sample index should be used instead.
    let customSampleBank: Int

    /// Whether this `BankHitSampleInfo` is layered.
    ///
    /// Layered hit samples are automatically added, but can be disabled using the layered skin config option.
    let isLayered: Bool

    private let _lookupNames: [String]

    override var lookupNames: [String] {
        _lookupNames
    }

    init(
        name: String,
        bank: SampleBank = .none,
        customSampleBank: Int = 0,
        volume: Int = 0,
        isLayered: Bool = false
    ) {
        self.name = name
        self.bank = bank
        self.customSampleBank = customSampleBank
        self.isLayered = isLayered

        var names = [String]()
        if customSampleBank >= 2 {
            names.append("\(bank.prefix)-\(name)\(customSampleBank)")
        }
        names.append("\(bank.prefix)-\(name)")
        names.append(name)
        self._lookupNames = names

        super.init(volume: volume)
    }

    func copy(
        name: String? = nil,
        bank: SampleBank? = nil,
        customSampleBank: Int? = nil,
        volume: Int? = nil,
        isLayered: Bool? = nil
    ) -> BankHitSampleInfo {
        BankHitSampleInfo(
            name: name ?? self.name,
            bank: bank ?? self.bank,
            customSampleBank: customSampleBank ?? self.customSampleBank,
            volume: volume ?? self.volume,
            isLayered: isLayered ?? self.isLayered
        )
    }
}

// MARK: - FileHitSampleInfo

/// Represents a custom gameplay hit sample that can be loaded from files.
class FileHitSampleInfo: HitSampleInfo {
    /// The name of the file to load the sample from.
    let filename: String

    private let _lookupNames: [String]

    override var lookupNames: [String] {
        _lookupNames
    }

    init(filename: String, volume: Int = 0) {
        self.filename = filename

        var names = [String]()
        names.append(filename)
        // Equivalent of File(filename).nameWithoutExtension
        let nameWithoutExtension = (filename as NSString).deletingPathExtension
        names.append(nameWithoutExtension)
        self._lookupNames = names

        super.init(volume: volume)
    }

    func copy(filename: String? = nil, volume: Int? = nil) -> FileHitSampleInfo {
        FileHitSampleInfo(
            filename: filename ?? self.filename,
            volume: volume ?? self.volume
        )
    }
}

// MARK: - SequenceHitSampleInfo

/// Represents a gameplay hit sample that is meant to be played sequentially at specific times.
class SequenceHitSampleInfo {
    /// The `HitSampleInfo`s to play, paired with the time at which they should be played.
    let samples: [(time: Double, sample: HitSampleInfo)]

    init(samples: [(Double, HitSampleInfo)]) {
        self.samples = samples
    }

    /// Whether this `SequenceHitSampleInfo` contains no `HitSampleInfo`s.
    func isEmpty() -> Bool {
        samples.isEmpty
    }

    /// Obtains the pair of `HitSampleInfo` and its time at a given index.
    subscript(index: Int) -> (time: Double, sample: HitSampleInfo) {
        samples[index]
    }

    /// Obtains the `HitSampleInfo` to play at a given time.
    ///
    /// - Parameter time: The time, in milliseconds.
    /// - Returns: The `HitSampleInfo` to play at the given time, or `nil` if no `HitSampleInfo`s should be played.
    func sampleAt(time: Double) -> HitSampleInfo? {
        if samples.isEmpty || time < samples[0].time {
            return nil
        }

        let lastSample = samples[samples.count - 1]
        if time >= lastSample.time {
            return lastSample.sample
        }

        var l = 0
        var r = samples.count - 2

        while l <= r {
            let pivot = l + (r - l) >> 1
            let sample = samples[pivot]

            if sample.time < time {
                l = pivot + 1
            } else if sample.time > time {
                r = pivot - 1
            } else {
                return sample.sample
            }
        }

        // l will be the first sample with time > sample.time, but we want the one before it
        return samples[l - 1].sample
    }
}
