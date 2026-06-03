/// A wrapper of `Color4` specifically for combo colors.
struct ComboColor: Equatable, Hashable {
    /// The index of this combo color.
    let index: Int

    /// The wrapped `Color4`.
    let color: Color4
}
