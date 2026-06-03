

/**
 * An public protocol for [Mod]s that make general adjustments to difficulty.
 *
 * This is used in place of [IModApplicableToDifficulty] to make adjustments that
 * correlates directly to other applied [Mod]s.
 *
 * [Mod]s marked by this public protocol will have their adjustments applied after
 * [IModApplicableToDifficulty] [Mod]s have been applied.
 */
public protocol IModApplicableToDifficultyWithMods {
    /**
     * Applies this [IModApplicableToDifficultyWithMods] to a [BeatmapDifficulty].
     *
     * This is typically called post beatmap conversion.
     *
     * @param mode The [GameMode] to apply for.
     * @param difficulty The [BeatmapDifficulty] to mutate.
     * @param mods The [Mod]s that are used.
     */
    func applyToDifficulty(mode: GameMode, difficulty: BeatmapDifficulty, mods: Iterable<Mod>)

}
