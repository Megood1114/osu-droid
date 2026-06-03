/// Represents a `ControlPoint` that changes a beatmap's BPM and time signature.
class TimingControlPoint: ControlPoint {
    /// The amount of milliseconds passed for each beat.
    let msPerBeat: Double

    /// The time signature at this `TimingControlPoint`.
    let timeSignature: Int

    /// The BPM at this `TimingControlPoint`.
    let bpm: Double

    /// Creates a new `TimingControlPoint`.
    ///
    /// - Parameters:
    ///   - time: The time at which this control point takes effect, in milliseconds.
    ///   - msPerBeat: The amount of milliseconds passed for each beat.
    ///   - timeSignature: The time signature at this control point.
    init(time: Double, msPerBeat: Double, timeSignature: Int) {
        self.msPerBeat = msPerBeat
        self.timeSignature = timeSignature
        self.bpm = 60000 / msPerBeat
        super.init(time: time)
    }

    // Timing points are never redundant as they can change the time signature.
    override func isRedundant(existing: ControlPoint) -> Bool {
        return false
    }
}
