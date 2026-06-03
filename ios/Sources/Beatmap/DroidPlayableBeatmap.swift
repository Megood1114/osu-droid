import Foundation

/// Represents a `PlayableBeatmap` for `GameMode.droid` game mode.
public class DroidPlayableBeatmap: PlayableBeatmap {
    public init(baseBeatmap: IBeatmap, mods: [Mod]? = nil) {
        super.init(baseBeatmap: baseBeatmap, mode: .droid, mods: mods)
    }
    
    override func createHitWindow() -> HitWindow {
        if mods.contains(where: { $0 is ModPrecise }) {
            return PreciseDroidHitWindow(overallDifficulty: Double(difficulty.od))
        } else {
            return DroidHitWindow(overallDifficulty: Double(difficulty.od))
        }
    }
}
