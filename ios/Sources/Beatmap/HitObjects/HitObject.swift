import Foundation

/// Represents a hit object.
class HitObject {
    // MARK: - Constants

    /// The radius of hit objects (i.e. the radius of a circle) relative to osu!standard.
    static let objectRadius: Float = 64

    /// A small adjustment to the start time of control points to account for rounding/precision errors.
    static let controlPointLeniency: Int = 5

    /// Maximum preempt time at AR=0.
    static let preemptMax: Double = 1800.0

    /// Median preempt time at AR=5.
    static let preemptMid: Double = 1200.0

    /// Minimum preempt time at AR=10.
    static let preemptMin: Double = 450.0

    // MARK: - Stored Properties

    /// The time at which this `HitObject` starts, in milliseconds.
    let startTime: Double

    /// Whether this `HitObject` starts a new combo.
    let isNewCombo: Bool

    /// When starting a new combo, the offset of the new combo relative to the current one.
    ///
    /// This is generally a setting provided by a beatmap creator to choreograph interesting color patterns
    /// which can only be achieved by skipping combo colors with per-`HitObject` level.
    ///
    /// It is exposed via `comboIndexWithOffsets`.
    let comboOffset: Int

    /// The end time of this `HitObject`.
    var endTime: Double {
        startTime
    }

    /// The duration of this `HitObject`, in milliseconds.
    var duration: Double {
        endTime - startTime
    }

    /// The position of this `HitObject` in osu!pixels.
    var position: Vector2 {
        didSet {
            difficultyStackedPositionCache.invalidate()
            gameplayStackedPositionCache.invalidate()
        }
    }

    /// The end position of this `HitObject` in osu!pixels.
    var endPosition: Vector2 {
        position
    }

    /// The index of this `HitObject` in the current combo.
    private(set) var indexInCurrentCombo: Int = 0

    /// The index of this `HitObject`'s combo in relation to the beatmap.
    ///
    /// In other words, this is incremented by 1 each time an `isNewCombo` is reached.
    private(set) var comboIndex: Int = 0

    /// The index of this `HitObject`'s combo in relation to the beatmap, with all aggregates applied.
    private(set) var comboIndexWithOffsets: Int = 0

    /// Whether this is the last `HitObject` in the current combo.
    var isLastInCombo: Bool = false

    /// The time at which the approach circle of this `HitObject` should appear before `startTime` in milliseconds.
    var timePreempt: Double = 600.0

    /// The time at which this `HitObject` should fade after this `HitObject` appears with respect to `timePreempt` in milliseconds.
    var timeFadeIn: Double = 400.0

    /// The samples to be played when this `HitObject` is hit.
    ///
    /// In the case of `Slider`s, this is the sample of the curve body
    /// and can be treated as the default samples for the `HitObject`.
    var samples = [HitSampleInfo]()

    /// Any samples which may be used by this `HitObject` that are non-standard.
    var auxiliarySamples = [SequenceHitSampleInfo]()

    /// Whether this `HitObject` is in kiai time.
    var kiai: Bool = false

    /// The `HitWindow` of this `HitObject`.
    var hitWindow: HitWindow? = nil

    /// Whether this `HitObject` is the first `HitObject` in the beatmap.
    var isFirstNote: Bool {
        comboIndex == 1 && indexInCurrentCombo == 0
    }

    /// The multiplier used to calculate stack offset.
    var stackOffsetMultiplier: Float = 0 {
        didSet {
            guard oldValue != stackOffsetMultiplier else { return }
            difficultyStackOffsetCache.invalidate()
            difficultyStackedPositionCache.invalidate()
            gameplayStackOffsetCache.invalidate()
            gameplayStackedPositionCache.invalidate()
        }
    }

    // MARK: - Difficulty Calculation Object Positions

    /// The stack height of this `HitObject` in difficulty calculation.
    var difficultyStackHeight: Int = 0 {
        didSet {
            guard oldValue != difficultyStackHeight else { return }
            difficultyStackOffsetCache.invalidate()
            difficultyStackedPositionCache.invalidate()
        }
    }

    /// The osu!standard scale of this `HitObject` in difficulty calculation.
    var difficultyScale: Float = 0 {
        didSet {
            guard oldValue != difficultyScale else { return }
            difficultyStackOffsetCache.invalidate()
            difficultyStackedPositionCache.invalidate()
        }
    }

    /// The radius of this `HitObject` in difficulty calculation, in osu!pixels.
    var difficultyRadius: Double {
        Double(HitObject.objectRadius * difficultyScale)
    }

    private let difficultyStackOffsetCache: Cached<Vector2>

    /// The stack offset of this `HitObject` in difficulty calculation, in osu!pixels.
    var difficultyStackOffset: Vector2 {
        if !difficultyStackOffsetCache.isValid {
            difficultyStackOffsetCache.value =
                Vector2(value: Float(difficultyStackHeight) * difficultyScale * stackOffsetMultiplier)
        }
        return difficultyStackOffsetCache.value
    }

    private let difficultyStackedPositionCache: Cached<Vector2>

    /// The stacked position of this `HitObject` in difficulty calculation, in osu!pixels.
    var difficultyStackedPosition: Vector2 {
        if !difficultyStackedPositionCache.isValid {
            difficultyStackedPositionCache.value = position + difficultyStackOffset
        }
        return difficultyStackedPositionCache.value
    }

    /// The stacked end position of this `HitObject` in difficulty calculation, in osu!pixels.
    var difficultyStackedEndPosition: Vector2 {
        difficultyStackedPosition
    }

    // MARK: - Gameplay Object Positions

    /// The stack height of this `HitObject` in gameplay.
    var gameplayStackHeight: Int = 0 {
        didSet {
            guard oldValue != gameplayStackHeight else { return }
            gameplayStackOffsetCache.invalidate()
            gameplayStackedPositionCache.invalidate()
        }
    }

    /// The scale of this `HitObject` in gameplay, in osu!pixels.
    var gameplayScale: Float = 0 {
        didSet {
            guard oldValue != gameplayScale else { return }
            gameplayStackOffsetCache.invalidate()
            gameplayStackedPositionCache.invalidate()
            screenSpaceGameplayStackedPositionCache.invalidate()
        }
    }

    /// The radius of this `HitObject` in gameplay, in osu!pixels.
    var gameplayRadius: Double {
        Double(HitObject.objectRadius * gameplayScale)
    }

    /// The scale of this `HitObject` in gameplay, in screen pixels.
    var screenSpaceGameplayScale: Float {
        gameplayScale * Float(AppConfig.renderHeight) / 480
    }

    /// The radius of this `HitObject` in gameplay, in screen pixels.
    var screenSpaceGameplayRadius: Double {
        Double(HitObject.objectRadius * screenSpaceGameplayScale)
    }

    private let gameplayStackOffsetCache: Cached<Vector2>

    /// The stack offset of this `HitObject` in gameplay, in osu!pixels.
    var gameplayStackOffset: Vector2 {
        if !gameplayStackOffsetCache.isValid {
            gameplayStackOffsetCache.value =
                Vector2(value: Float(gameplayStackHeight) * gameplayScale * stackOffsetMultiplier)
        }
        return gameplayStackOffsetCache.value
    }

    private let gameplayStackedPositionCache: Cached<Vector2>

    /// The stacked position of this `HitObject` in gameplay, in osu!pixels.
    var gameplayStackedPosition: Vector2 {
        if !gameplayStackedPositionCache.isValid {
            gameplayStackedPositionCache.value = position + gameplayStackOffset
        }
        return gameplayStackedPositionCache.value
    }

    /// The stacked end position of this `HitObject` in gameplay, in osu!pixels.
    var gameplayStackedEndPosition: Vector2 {
        gameplayStackedPosition
    }

    private let screenSpaceGameplayPositionCache: Cached<Vector2>

    /// The position of this `HitObject` in gameplay, in screen pixels.
    var screenSpaceGameplayPosition: Vector2 {
        if !screenSpaceGameplayPositionCache.isValid {
            screenSpaceGameplayPositionCache.value = convertPositionToRealCoordinates(position)
        }
        return screenSpaceGameplayPositionCache.value
    }

    private let screenSpaceGameplayStackedPositionCache: Cached<Vector2>

    /// The stacked position of this `HitObject` in gameplay, in screen pixels.
    var screenSpaceGameplayStackedPosition: Vector2 {
        if !screenSpaceGameplayStackedPositionCache.isValid {
            screenSpaceGameplayStackedPositionCache.value =
                convertPositionToRealCoordinates(gameplayStackedPosition)
        }
        return screenSpaceGameplayStackedPositionCache.value
    }

    /// The stacked end position of this `HitObject` in gameplay, in screen pixels.
    var screenSpaceGameplayStackedEndPosition: Vector2 {
        screenSpaceGameplayStackedPosition
    }

    // MARK: - Initialization

    /// Creates a new `HitObject`.
    ///
    /// - Parameters:
    ///   - startTime: The time at which this `HitObject` starts, in milliseconds.
    ///   - position: The position of this `HitObject` in osu!pixels.
    ///   - isNewCombo: Whether this `HitObject` starts a new combo.
    ///   - comboOffset: When starting a new combo, the offset of the new combo relative to the current one.
    init(startTime: Double, position: Vector2, isNewCombo: Bool, comboOffset: Int) {
        self.startTime = startTime
        self.position = position
        self.isNewCombo = isNewCombo
        self.comboOffset = comboOffset

        // Initialize caches
        self.difficultyStackOffsetCache = Cached(Vector2(value: 0))
        self.difficultyStackedPositionCache = Cached(position)
        self.gameplayStackOffsetCache = Cached(Vector2(value: 0))
        self.gameplayStackedPositionCache = Cached(position)
        self.screenSpaceGameplayPositionCache = Cached(Vector2.zero)
        self.screenSpaceGameplayStackedPositionCache = Cached(Vector2.zero)
    }

    // MARK: - Methods

    /// Applies defaults to this `HitObject`.
    ///
    /// - Parameters:
    ///   - controlPoints: The control points.
    ///   - difficulty: The difficulty settings to use.
    ///   - mode: The `GameMode` to use.
    func applyDefaults(controlPoints: BeatmapControlPoints, difficulty: BeatmapDifficulty, mode: GameMode) {
        kiai = controlPoints.effect.controlPointAt(startTime + Double(HitObject.controlPointLeniency)).isKiai

        if hitWindow == nil {
            hitWindow = createHitWindow(mode: mode)
        }

        if let hw = hitWindow {
            hw.overallDifficulty = Double(difficulty.od)
        }

        timePreempt = Double(BeatmapDifficulty.difficultyRangeInt(
            difficulty: Double(difficulty.ar),
            min: HitObject.preemptMax,
            mid: HitObject.preemptMid,
            max: HitObject.preemptMin
        ))

        // Preempt time can go below 450ms. Normally, this is achieved via the DT mod which uniformly speeds up
        // all animations game wide regardless of AR.
        // This uniform speedup is hard to match 1:1, however we can at least make AR>10 (via mods) feel good
        // by extending the upper linear function above.
        // Note that this doesn't exactly match the AR>10 visuals as they're classically known, but it feels good.
        // This adjustment is necessary for AR>10, otherwise timePreempt can become smaller leading to hit circles
        // not fully fading in.
        timeFadeIn = 400 * min(1.0, timePreempt / HitObject.preemptMin)

        stackOffsetMultiplier = {
            switch mode {
            case .droid: return -4
            case .standard: return -6.4
            }
        }()

        difficultyScale = {
            switch mode {
            case .droid:
                return CircleSizeCalculator.droidCSToDroidScale(difficulty.difficultyCS)
            case .standard:
                return CircleSizeCalculator.standardCSToStandardScale(difficulty.gameplayCS, applyFudge: true)
            }
        }()

        gameplayScale = difficultyScale
    }

    /// Applies samples to this `HitObject`.
    ///
    /// - Parameter controlPoints: The control points.
    func applySamples(controlPoints: BeatmapControlPoints) {
        let sampleControlPoint = controlPoints.sample.controlPointAt(
            endTime + Double(HitObject.controlPointLeniency)
        )

        samples = samples.map { sampleControlPoint.applyTo($0) }
    }

    /// Given the previous `HitObject` in the beatmap, update relevant combo information.
    func updateComboInformation(lastObj: HitObject?) {
        comboIndex = lastObj?.comboIndex ?? 0
        comboIndexWithOffsets = lastObj?.comboIndexWithOffsets ?? 0
        indexInCurrentCombo = lastObj != nil ? lastObj!.indexInCurrentCombo + 1 : 0

        if isNewCombo || lastObj == nil || lastObj is Spinner {
            indexInCurrentCombo = 0
            comboIndex += 1

            if !(self is Spinner) {
                // Spinners do not affect combo color offsets.
                comboIndexWithOffsets += comboOffset + 1
            }

            if let lastObj = lastObj {
                lastObj.isLastInCombo = true
            }
        }
    }

    /// Converts a position in osu!pixels to real screen coordinates.
    ///
    /// - Parameter position: The position in osu!pixels.
    /// - Returns: The position in real screen coordinates.
    func convertPositionToRealCoordinates(_ position: Vector2) -> Vector2 {
        // Scale the position to the actual playfield size on screen.
        let xScale = GameConstants.mapActualWidth / Float(GameConstants.mapWidth)
        let yScale = GameConstants.mapActualHeight / Float(GameConstants.mapHeight)

        // Center the position on the screen.
        let xOffset = (Float(AppConfig.renderWidth) - GameConstants.mapActualWidth) / 2
        let yOffset = (Float(AppConfig.renderHeight) - GameConstants.mapActualHeight) / 2

        return Vector2(x: position.x * xScale + xOffset, y: position.y * yScale + yOffset)
    }

    /// Creates a `BankHitSampleInfo` based on the sample settings of the first `BankHitSampleInfo.hitNormal`
    /// sample in `samples`.
    /// If no sample is available, sane default settings will be used instead.
    ///
    /// In the case an existing sample exists, all settings apart from the sample name will be inherited.
    /// This includes volume and bank.
    ///
    /// - Parameter sampleName: The name of the sample.
    /// - Returns: A populated `BankHitSampleInfo`.
    func createHitSampleInfo(_ sampleName: String) -> BankHitSampleInfo {
        if let existing = samples.compactMap({ $0 as? BankHitSampleInfo }).first(where: { $0.name == BankHitSampleInfo.hitNormal }) {
            return existing.copy(name: sampleName)
        }
        return BankHitSampleInfo(name: sampleName, bank: .normal)
    }

    /// Creates the `HitWindow` of this `HitObject`.
    ///
    /// A `nil` return means that this `HitObject` has no `HitWindow` and timing errors should not be displayed
    /// to the user.
    ///
    /// This will only be called if this `HitObject`'s `HitWindow` has not been set externally.
    ///
    /// - Parameter mode: The `GameMode` to create the `HitWindow` for.
    /// - Returns: The created `HitWindow`.
    func createHitWindow(mode: GameMode) -> HitWindow? {
        switch mode {
        case .droid:
            return DroidHitWindow()
        case .standard:
            return StandardHitWindow()
        }
    }
}
