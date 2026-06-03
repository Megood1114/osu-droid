

/**
 * An public protocol for [Mod]s that applies changes to a [Beatmap] after conversion and post-processing has completed.
 */
public protocol IModApplicableToBeatmap {
    /**
     * Applies this [IModApplicableToBeatmap] to a [Beatmap].
     *
     * @param beatmap The [Beatmap] to apply to.
     * @param scope The [CoroutineScope] to use for the operation.
     */
    func applyToBeatmap(beatmap: Beatmap, scope: CoroutineScope? = null)
}
