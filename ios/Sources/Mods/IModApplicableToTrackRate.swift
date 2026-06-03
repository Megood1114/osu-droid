
/**
 * An public protocol for [Mod]s that make adjustments to the track's playback rate.
 */
public protocol IModApplicableToTrackRate {
    /**
     * Returns the playback rate at [time] after this [Mod] is applied.
     *
     * @param time The time at which the playback rate is queried, in milliseconds.
     * @param rate The playback rate before applying this [Mod].
     * @return The playback rate after applying this [Mod].
     */
    func applyToRate(_ time: Double, _ rate: Float) -> Float
}
