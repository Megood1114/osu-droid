/// Represents various hit object types.
struct HitObjectType: OptionSet {
    let rawValue: Int

    /// A normal hit circle.
    static let normal           = HitObjectType(rawValue: 1)
    /// A slider.
    static let slider           = HitObjectType(rawValue: 2)
    /// Indicates that this hit object starts a new combo.
    static let newCombo         = HitObjectType(rawValue: 4)
    /// A normal hit circle that starts a new combo.
    static let normalNewCombo   = HitObjectType(rawValue: 5)
    /// A slider that starts a new combo.
    static let sliderNewCombo   = HitObjectType(rawValue: 6)
    /// A spinner.
    static let spinner          = HitObjectType(rawValue: 8)
    /// The combo color offset bits.
    static let comboColorOffset = HitObjectType(rawValue: (1 << 4) | (1 << 5) | (1 << 6))
}
