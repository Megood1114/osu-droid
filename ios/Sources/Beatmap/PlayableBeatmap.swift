import Foundation

/// Represents an `IBeatmap` that is in a playable state in a specific `GameMode`.
open class PlayableBeatmap: IBeatmap {
    /// The `GameMode` this `PlayableBeatmap` was parsed as.
    public let mode: GameMode
    
    /// The `Mod`s that were applied to this `PlayableBeatmap`.
    public let mods: [Mod]
    
    public var formatVersion: Int { baseBeatmap.formatVersion }
    public var general: BeatmapGeneral { baseBeatmap.general }
    public var metadata: BeatmapMetadata { baseBeatmap.metadata }
    public var difficulty: BeatmapDifficulty { baseBeatmap.difficulty }
    public var events: BeatmapEvents { baseBeatmap.events }
    public var colors: BeatmapColor { baseBeatmap.colors }
    public var controlPoints: BeatmapControlPoints { baseBeatmap.controlPoints }
    var hitObjects: BeatmapHitObjects { baseBeatmap.hitObjects }
    public var filePath: String { baseBeatmap.filePath }
    public var md5: String { baseBeatmap.md5 }
    public var maxCombo: Int { baseBeatmap.maxCombo }
    
    private let baseBeatmap: IBeatmap
    
    /// The speed multiplier that was applied to this `PlayableBeatmap`.
    public let speedMultiplier: Float
    
    /// The `HitWindow` of this `PlayableBeatmap`.
    lazy var hitWindow: HitWindow = {
        return createHitWindow()
    }()
    
    public init(baseBeatmap: IBeatmap, mode: GameMode, mods: [Mod]? = nil) {
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
