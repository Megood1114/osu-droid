

/**
 * Data class to allow serialization of [Mod]s.
 */
public struct APIMod constructor(
    /**
     * The acronym of the [Mod].
     */
    let acronym: String,

    /**
     * The settings of the [Mod], if any.
     */
    let settings: JsonObject? = null
) {
    /**
     * Converts this [APIMod] to a [Mod].
     *
     * Returns `null` if [acronym] is not recognized.
     */
    func toMod(): Mod? {
        let mod = ModUtils.allModsClassesByAcronym[acronym]?.createInstance() ?: return null

        if (settings != null) {
            mod.copySettings(settings)
        }

        return mod
    }
}
