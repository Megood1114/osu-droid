import Foundation

/// Represents a slider tick.
class SliderTick: SliderHitObject {
    /// The index of the span at which this `SliderTick` lies.
    private let spanIndex: Int

    /// The start time of the span at which this `SliderTick` lies, in milliseconds.
    private let spanStartTime: Double

    /// Creates a new `SliderTick`.
    ///
    /// - Parameters:
    ///   - startTime: The time at which this `SliderTick` starts, in milliseconds.
    ///   - position: The position of this `SliderTick` relative to the play field.
    ///   - spanIndex: The index of the span at which this `SliderTick` lies.
    ///   - spanStartTime: The start time of the span at which this `SliderTick` lies, in milliseconds.
    init(startTime: Double, position: Vector2, spanIndex: Int, spanStartTime: Double) {
        self.spanIndex = spanIndex
        self.spanStartTime = spanStartTime
        super.init(startTime: startTime, position: position)
    }

    override func applyDefaults(controlPoints: BeatmapControlPoints, difficulty: BeatmapDifficulty, mode: GameMode) {
        super.applyDefaults(controlPoints: controlPoints, difficulty: difficulty, mode: mode)

        // Adding 200 to include the offset stable used.
        // This is so on repeats ticks don't appear too late to be visually processed by the player.
        let offset: Double = spanIndex > 0 ? 200.0 : timePreempt * 0.66

        timePreempt = (startTime - spanStartTime) / 2 + offset
    }

    override func createHitWindow(mode: GameMode) -> HitWindow? {
        EmptyHitWindow()
    }
}
