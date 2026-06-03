

/**
 * An public protocol for [Mod]s that can be applied to [HitObject]s.
 *
 * This is used in place of [IModApplicableToHitObject] to make adjustments that
 * correlates directly to other applied [Mod]s.
 *
 * [Mod]s marked by this public protocol will have their adjustments applied after
 * [IModApplicableToHitObject] [Mod]s have been applied.
 */
public protocol IModApplicableToHitObjectWithMods {
    /**
     * Applies this [IModApplicableToHitObjectWithMods] to a [HitObject].
     *
     * This is typically called post beatmap conversion.
     *
     * @param mode The [GameMode] to apply for.
     * @param hitObject The [HitObject] to mutate.
     * @param mods The [Mod]s that are used.
     * @param scope The [CoroutineScope] to use for the operation.
     */
    func applyToHitObject(_ mode: GameMode, _ hitObject: HitObject, _ mods: [Mod])
}
