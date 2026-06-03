/// Represents a `ControlPoint` that handles sound samples.
class SampleControlPoint: ControlPoint {
    /// The sample bank at this `SampleControlPoint`.
    let sampleBank: SampleBank

    /// The sample volume at this `SampleControlPoint`.
    let sampleVolume: Int

    /// The index of the sample bank, if this sample bank uses custom samples.
    ///
    /// If this is 0, the beatmap's sample should be used instead.
    let customSampleBank: Int

    /// Creates a new `SampleControlPoint`.
    ///
    /// - Parameters:
    ///   - time: The time at which this control point takes effect, in milliseconds.
    ///   - sampleBank: The sample bank.
    ///   - sampleVolume: The sample volume.
    ///   - customSampleBank: The index of the custom sample bank.
    init(time: Double, sampleBank: SampleBank, sampleVolume: Int, customSampleBank: Int) {
        self.sampleBank = sampleBank
        self.sampleVolume = sampleVolume
        self.customSampleBank = customSampleBank
        super.init(time: time)
    }

    override func isRedundant(existing: ControlPoint) -> Bool {
        guard let existing = existing as? SampleControlPoint else {
            return false
        }

        return sampleBank == existing.sampleBank &&
               sampleVolume == existing.sampleVolume &&
               customSampleBank == existing.customSampleBank
    }

    /// Applies `sampleBank` and `sampleVolume` to a `HitSampleInfo` if necessary, returning the modified `HitSampleInfo`.
    ///
    /// - Parameter hitSampleInfo: The `HitSampleInfo`. This will not be modified.
    /// - Returns: The modified `HitSampleInfo`. This does not share a reference with `hitSampleInfo`.
    func applyTo(hitSampleInfo: HitSampleInfo) -> HitSampleInfo {
        let volume = hitSampleInfo.volume > 0 ? hitSampleInfo.volume : sampleVolume

        if let h = hitSampleInfo as? FileHitSampleInfo {
            return h.withVolume(volume)
        } else if let h = hitSampleInfo as? BankHitSampleInfo {
            return h.with(
                volume: volume,
                bank: h.bank != .none ? h.bank : sampleBank,
                customSampleBank: h.customSampleBank > 0 ? h.customSampleBank : customSampleBank
            )
        } else {
            fatalError("Unknown type of hit sample.")
        }
    }
}
