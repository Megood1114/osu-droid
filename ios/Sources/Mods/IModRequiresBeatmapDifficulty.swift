

/**
 * An public protocol for [Mod]s that require the original instance of a [BeatmapDifficulty] to perform conversion and processing.
 */
public protocol IModRequiresBeatmapDifficulty {
    /**
     * Applies this [IModRequiresBeatmapDifficulty] from a [BeatmapDifficulty].
     *
     * This is called before conversion and processing.
     *
     * @param difficulty The [BeatmapDifficulty] to apply from.
     */
    func applyFromBeatmapDifficulty(difficulty: BeatmapDifficulty)
}