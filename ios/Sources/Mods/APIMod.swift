

/**
 * Data class to allow serialization of [Mod]s.
 */
public struct APIMod {
    let acronym: String
    let settings: [String: Any]?

    public init(acronym: String, settings: [String: Any]? = nil) {
        self.acronym = acronym
        self.settings = settings
    }
}
