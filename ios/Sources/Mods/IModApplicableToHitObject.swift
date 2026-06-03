

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
    func applyToHitObject(_ mode: GameMode, _ hitObject: HitObject, _ adjustmentMods: [IModFacilitatesAdjustment])
}
