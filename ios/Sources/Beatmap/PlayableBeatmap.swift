import Foundation

/// Represents an `IBeatmap` that is in a playable state in a specific `GameMode`.
class PlayableBeatmap: IBeatmap {
    /// The `GameMode` this `PlayableBeatmap` was parsed as.
    let mode: GameMode
    
    /// The `Mod`s that were applied to this `PlayableBeatmap`.
    let mods: [Mod]
    
    var formatVersion: Int { baseBeatmap.formatVersion }
    var general: BeatmapGeneral { baseBeatmap.general }
    var metadata: BeatmapMetadata { baseBeatmap.metadata }
    var difficulty: BeatmapDifficulty { baseBeatmap.difficulty }
    var events: BeatmapEvents { baseBeatmap.events }
    var colors: BeatmapColor { baseBeatmap.colors }
    var controlPoints: BeatmapControlPoints { baseBeatmap.controlPoints }
    var hitObjects: BeatmapHitObjects { baseBeatmap.hitObjects }
    var filePath: String { baseBeatmap.filePath }
    var md5: String { baseBeatmap.md5 }
    var maxCombo: Int { baseBeatmap.maxCombo }
    
    private let baseBeatmap: IBeatmap
    
    /// The speed multiplier that was applied to this `PlayableBeatmap`.
    let speedMultiplier: Float
    
    /// The `HitWindow` of this `PlayableBeatmap`.
    lazy var hitWindow: HitWindow = {
        return createHitWindow()
    }()
    
    init(baseBeatmap: IBeatmap, mode: GameMode, mods: [Mod]? = nil) {
        self.baseBeatmap = baseBeatmap
        self.mode = mode
        self.mods = mods ?? []
        if let mods = mods {
            self.speedMultiplier = mods.compactMap { $0 as? ModRateAdjust }.reduce(1.0) { $0 * $1.trackRateMultiplier }
        } else {
            self.speedMultiplier = 1.0
        }
    }
    
    /// Creates the `HitWindow` of this `PlayableBeatmap`.
    func createHitWindow() -> HitWindow {
        fatalError("createHitWindow() must be overridden")
    }
}
