import Foundation

/// Contains information about combo and skin colors of a beatmap.
public class BeatmapColor {
    /// The combo colors of this beatmap.
    public var comboColors: [ComboColor] = []

    /// The color of the slider border.
    public var sliderBorderColor: Color4? = nil
    
    public init() {}
}
