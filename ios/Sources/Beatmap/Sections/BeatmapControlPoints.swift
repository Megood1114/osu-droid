import Foundation

/// Contains information about the timing (control) points of a beatmap.
public class BeatmapControlPoints {
    /// The manager for timing control points of this beatmap.
    let timing = TimingControlPointManager()

    /// The manager for difficulty control points of this beatmap.
    let difficulty = DifficultyControlPointManager()

    /// The manager for effect control points of this beatmap.
    let effect = EffectControlPointManager()

    /// The manager for sample control points of this beatmap.
    let sample = SampleControlPointManager()
    
    public init() {}

    /// Obtains the beat divisor closest to `time`. If two are equally close, the smallest divisor is returned.
    ///
    /// - Parameter time: The time to find the closest beat snap divisor for.
    /// - Returns: The closest beat snap divisor to `time`.
    public func getClosestBeatDivisor(time: Double) -> Int {
        let timingPoint = timing.controlPointAt(time: time)

        var closestDivisor = 0
        var closestTime = Double.greatestFiniteMagnitude

        for divisor in BeatmapControlPoints.predefinedDivisors {
            let distanceFromSnap = abs(time - BeatmapControlPoints.getClosestSnappedTime(timingPoint: timingPoint, time: time, beatDivisor: divisor))

            if Precision.definitelyBigger(closestTime, distanceFromSnap) {
                closestDivisor = divisor
                closestTime = distanceFromSnap
            }
        }

        return closestDivisor
    }

    /// Beat snap divisors that are commonly used in beatmaps.
    public static let predefinedDivisors: [Int] = [1, 2, 3, 4, 6, 8, 12, 16]

    private static func getClosestSnappedTime(timingPoint: TimingControlPoint, time: Double, beatDivisor: Int) -> Double {
        let beatLength = timingPoint.msPerBeat / Double(beatDivisor)
        let beats = round((max(time, 0.0) - timingPoint.time) / beatLength)

        let snappedTime = timingPoint.time + beats * beatLength

        return snappedTime + (snappedTime >= 0 ? 0.0 : beatLength)
    }
}
