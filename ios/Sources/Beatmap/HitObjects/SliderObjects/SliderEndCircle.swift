import Foundation

/// Represents a `SliderHitObject` that is at the end of a `Slider`'s path.
class SliderEndCircle: SliderHitObject {
    /// The `Slider` to which this `SliderEndCircle` belongs to.
    let slider: Slider

    /// The index of the span at which this `SliderEndCircle` lies.
    let spanIndex: Int

    /// Creates a new `SliderEndCircle`.
    ///
    /// - Parameters:
    ///   - slider: The `Slider` to which this `SliderEndCircle` belongs to.
    ///   - spanIndex: The index of the span at which this `SliderEndCircle` lies.
    init(slider: Slider, spanIndex: Int) {
        self.slider = slider
        self.spanIndex = spanIndex

        let time = slider.startTime + slider.spanDuration * Double(spanIndex + 1)
        let pos = spanIndex % 2 == 0 ? slider.endPosition : slider.position

        super.init(startTime: time, position: pos)
    }

    override func applyDefaults(controlPoints: BeatmapControlPoints, difficulty: BeatmapDifficulty, mode: GameMode) {
        super.applyDefaults(controlPoints: controlPoints, difficulty: difficulty, mode: mode)

        if spanIndex > 0 {
            // Repeat points after the first span should appear behind the still-visible one.
            timeFadeIn = 0.0

            // The next end circle should appear exactly after the previous circle (on the same end) is hit.
            timePreempt = slider.spanDuration * 2
        } else {
            // The first end circle should fade in with the slider.
            timePreempt += startTime - slider.startTime
        }
    }

    override func createHitWindow(mode: GameMode) -> HitWindow? {
        EmptyHitWindow()
    }
}
