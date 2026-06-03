import Foundation

/// Represents a `PlayableBeatmap` for `GameMode.standard` game mode.
class StandardPlayableBeatmap: PlayableBeatmap {
    init(baseBeatmap: IBeatmap, mods: [Mod]? = nil) {
        super.init(baseBeatmap: baseBeatmap, mode: .standard, mods: mods)
    }
    
    override func createHitWindow() -> HitWindow {
        return StandardHitWindow(overallDifficulty: Double(difficulty.od))
    }
}
