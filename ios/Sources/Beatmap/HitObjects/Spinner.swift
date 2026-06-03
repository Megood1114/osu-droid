import Foundation

/// Represents a spinner.
class Spinner: HitObject {
    /// The end time of this `Spinner`.
    private let _endTime: Double

    override var endTime: Double {
        _endTime
    }

    override var difficultyStackedPosition: Vector2 {
        position
    }

    override var difficultyStackedEndPosition: Vector2 {
        position
    }

    override var gameplayStackedPosition: Vector2 {
        position
    }

    override var gameplayStackedEndPosition: Vector2 {
        position
    }

    override var screenSpaceGameplayStackedPosition: Vector2 {
        screenSpaceGameplayPosition
    }

    override var screenSpaceGameplayStackedEndPosition: Vector2 {
        screenSpaceGameplayPosition
    }

    private static let baseSpinnerSpinSample = BankHitSampleInfo(name: "spinnerspin")
    private static let baseSpinnerBonusSample = BankHitSampleInfo(name: "spinnerbonus")

    /// Creates a new `Spinner`.
    ///
    /// - Parameters:
    ///   - startTime: The time at which this `Spinner` starts, in milliseconds.
    ///   - endTime: The time at which this `Spinner` ends, in milliseconds.
    ///   - isNewCombo: Whether this `Spinner` starts a new combo.
    init(startTime: Double, endTime: Double, isNewCombo: Bool) {
        self._endTime = endTime
        super.init(startTime: startTime, position: Vector2(x: 256, y: 192), isNewCombo: isNewCombo, comboOffset: 0)
    }

    override func applySamples(controlPoints: BeatmapControlPoints) {
        super.applySamples(controlPoints: controlPoints)

        let samplePoints = controlPoints.sample.between(
            startTime + Double(HitObject.controlPointLeniency),
            endTime + Double(HitObject.controlPointLeniency)
        )

        auxiliarySamples.removeAll()

        auxiliarySamples.append(SequenceHitSampleInfo(
            samples: samplePoints.map { point in
                (point.time, point.applyTo(Spinner.baseSpinnerSpinSample))
            }
        ))

        auxiliarySamples.append(SequenceHitSampleInfo(
            samples: samplePoints.map { point in
                (point.time, point.applyTo(Spinner.baseSpinnerBonusSample))
            }
        ))
    }

    override func createHitWindow(mode: GameMode) -> HitWindow? {
        EmptyHitWindow()
    }
}
