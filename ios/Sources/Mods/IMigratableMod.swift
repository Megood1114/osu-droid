

/**
 * An public protocol for [Mod]s that are no longer available to be selected by the user, but can be migrated into a new [Mod].
 */
public protocol IMigratableMod {
    /**
     * Migrates this [IMigratableMod] to a new [Mod].
     *
     * @param difficulty The [BeatmapDifficulty] to migrate this [IMigratableMod] against.
     * @return The new [Mod].
     */
    func migrate(difficulty: BeatmapDifficulty) -> Mod
}
