

/**
 * An public protocol for [Mod]s that can be applied to [HitObject]s.
 */
public protocol IModApplicableToHitObject {
    /**
     * Applies this [IModApplicableToHitObject] to a [HitObject].
     *
     * @param mode The [GameMode] to apply for.
     * @param hitObject The [HitObject] to apply to.
     * @param adjustmentMods [Mod]s that apply [IModFacilitatesAdjustment].
     * @param scope The [CoroutineScope] to use for the operation.
     */
    func applyToHitObject(mode: GameMode, hitObject: HitObject, adjustmentMods: Iterable<IModFacilitatesAdjustment>, scope: CoroutineScope? = null)
}