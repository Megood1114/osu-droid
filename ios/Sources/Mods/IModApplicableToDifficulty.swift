

/**
 * An public protocol for [Mod]s that make general adjustments to difficulty.
 */
public protocol IModApplicableToDifficulty {
    /**
     * Applies this [IModApplicableToDifficulty] to a [BeatmapDifficulty].
     *
     * This is typically called post beatmap conversion.
     *
     * @param mode The [GameMode] to apply for.
     * @param difficulty The [BeatmapDifficulty] to mutate.
     * @param adjustmentMods [Mod]s that apply [IModFacilitatesAdjustment].
     */
    func applyToDifficulty(
        mode: GameMode,
        difficulty: BeatmapDifficulty,
        adjustmentMods: Iterable<IModFacilitatesAdjustment>
    )
}