import Foundation

/// Represents a `PlayableBeatmap` for `GameMode.standard` game mode.
public class StandardPlayableBeatmap: PlayableBeatmap {
    public init(baseBeatmap: IBeatmap, mods: [Mod]? = nil) {
        super.init(baseBeatmap: baseBeatmap, mode: .standard, mods: mods)
    }
    
    public override func createHitWindow() -> HitWindow {
        return StandardHitWindow(difficulty.od)
    }
}
