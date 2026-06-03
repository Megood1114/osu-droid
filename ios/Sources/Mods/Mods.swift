import Foundation

public class ModApproachDifferent: Mod {
    public override var name: String { "Approach Different" }
    public override var acronym: String { "AD" }
    public override var description: String { "Never trust the approach circles..." }
    public override var type: ModType { .fun }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModHidden.self, ModFreezeFrame.self] }
}

public class ModAutopilot: Mod {
    public override var name: String { "Autopilot" }
    public override var acronym: String { "AP" }
    public override var description: String { "Automatic cursor movement - just follow the rhythm." }
    public override var type: ModType { .automation }
    public override var iconTextureNameSuffix: String { "relax2" }
    public override var scoreMultiplier: Float { 0.001 }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModRelax.self, ModAutoplay.self, ModNoFail.self] }
}

public class ModAutoplay: Mod {
    public override var name: String { "Autoplay" }
    public override var acronym: String { "AT" }
    public override var description: String { "Watch a perfect automated play through the song." }
    public override var type: ModType { .automation }
    public override var isValidForMultiplayer: Bool { false }
    public override var isValidForMultiplayerAsFreeMod: Bool { false }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModRelax.self, ModAutopilot.self, ModPerfect.self, ModSuddenDeath.self] }
}

open class ModRateAdjust: Mod {
    open var trackRateMultiplier: Float
    
    public init(trackRateMultiplier: Float = 1.0) {
        self.trackRateMultiplier = trackRateMultiplier
        super.init()
    }
}

public class ModCustomSpeed: ModRateAdjust {
    public override var name: String { "Custom Speed" }
    public override var acronym: String { "CS" }
    public override var description: String { "Play at any speed you want - slow or fast." }
    public override var type: ModType { .conversion }
    public override var isRanked: Bool { true }
    public override var requiresConfiguration: Bool { true }
}

public class ModDifficultyAdjust: Mod, IModApplicableToDifficultyWithMods, IModApplicableToHitObjectWithMods, IModRequiresBeatmapDifficulty {
    public override var name: String { "Difficulty Adjust" }
    public override var acronym: String { "DA" }
    public override var description: String { "Override a beatmap's difficulty settings." }
    public override var type: ModType { .conversion }
    public override var requiresConfiguration: Bool { true }
    
    public var cs: Float?
    public var ar: Float?
    public var od: Float?
    public var hp: Float?
    
    public init(cs: Float? = nil, ar: Float? = nil, od: Float? = nil, hp: Float? = nil) {
        self.cs = cs
        self.ar = ar
        self.od = od
        self.hp = hp
        super.init()
    }
    
    public func applyToDifficulty(mode: GameMode, difficulty: BeatmapDifficulty, mods: [Mod]) {}
    func applyToHitObject(mode: GameMode, hitObject: HitObject, mods: [Mod]) {}
    public func applyFromBeatmapDifficulty(difficulty: BeatmapDifficulty) {}
}

public class ModDoubleTime: ModRateAdjust {
    public override var name: String { "Double Time" }
    public override var acronym: String { "DT" }
    public override var description: String { "Zoooooooooom..." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModNightCore.self, ModHalfTime.self] }
    
    public init() {
        super.init(trackRateMultiplier: 1.5)
    }
}

public class ModEasy: Mod {
    public override var name: String { "Easy" }
    public override var acronym: String { "EZ" }
    public override var description: String { "Larger circles, more forgiving HP drain, less accuracy required, and three lives!" }
    public override var type: ModType { .difficultyReduction }
    public override var isRanked: Bool { true }
    public override var scoreMultiplier: Float { 0.5 }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModHardRock.self] }
}

public class ModFlashlight: Mod {
    public override var name: String { "Flashlight" }
    public override var acronym: String { "FL" }
    public override var description: String { "Restricted view area." }
    public override var type: ModType { .difficultyIncrease }
}

public class ModFreezeFrame: Mod {
    public override var name: String { "Freeze Frame" }
    public override var acronym: String { "FR" }
    public override var description: String { "Burn the notes into your memory." }
    public override var type: ModType { .fun }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModApproachDifferent.self, ModHidden.self] }
}

public class ModHalfTime: ModRateAdjust {
    public override var name: String { "Half Time" }
    public override var acronym: String { "HT" }
    public override var description: String { "Less zoom..." }
    public override var type: ModType { .difficultyReduction }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModDoubleTime.self, ModNightCore.self] }
    
    public init() {
        super.init(trackRateMultiplier: 0.75)
    }
}

public class ModHardRock: Mod {
    public override var name: String { "Hard Rock" }
    public override var acronym: String { "HR" }
    public override var description: String { "Everything just got a bit harder..." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModEasy.self, ModMirror.self] }
    public override var scoreMultiplier: Float { 1.06 }
}

open class ModWithVisibilityAdjustment: Mod {
    // Base class for visibility adjustment mods
}

public class ModHidden: ModWithVisibilityAdjustment {
    /// The multiplier applied to the fade out duration of hit objects.
    public static let fadeOutDurationMultiplier: Double = 0.3

    public override var name: String { "Hidden" }
    public override var acronym: String { "HD" }
    public override var description: String { "Play with no approach circles and fading circles/sliders." }
    public override var type: ModType { .difficultyIncrease }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModTraceable.self, ModApproachDifferent.self, ModFreezeFrame.self] }
}

public class ModMirror: Mod {
    public override var name: String { "Mirror" }
    public override var acronym: String { "MR" }
    public override var description: String { "Flip objects on the chosen axes." }
    public override var type: ModType { .conversion }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModHardRock.self] }
}

public class ModMuted: Mod {
    public override var name: String { "Muted" }
    public override var acronym: String { "MU" }
    public override var description: String { "Can you still feel the rhythm without music?" }
    public override var type: ModType { .fun }
}

public class ModNightCore: ModRateAdjust {
    public override var name: String { "Nightcore" }
    public override var acronym: String { "NC" }
    public override var description: String { "Uguuuuuuuu..." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModDoubleTime.self, ModHalfTime.self] }
    
    public init() {
        super.init(trackRateMultiplier: 1.5)
    }
}

public class ModNoFail: Mod {
    public override var name: String { "No Fail" }
    public override var acronym: String { "NF" }
    public override var description: String { "You can't fail, no matter what." }
    public override var type: ModType { .difficultyReduction }
    public override var isRanked: Bool { true }
    public override var scoreMultiplier: Float { 0.5 }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModSuddenDeath.self, ModPerfect.self, ModAutopilot.self, ModRelax.self] }
}

public class ModOldNightCore: ModNightCore {
    public override var scoreMultiplier: Float { 1.12 }
}

public class ModPerfect: Mod {
    public override var name: String { "Perfect" }
    public override var acronym: String { "PF" }
    public override var description: String { "SS or quit." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModSuddenDeath.self, ModNoFail.self, ModAutoplay.self] }
}

public class ModPrecise: Mod {
    public override var name: String { "Precise" }
    public override var acronym: String { "PR" }
    public override var description: String { "Ultimate rhythm gamer timing." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var scoreMultiplier: Float { 1.06 }
}

public class ModRandom: Mod {
    public override var name: String { "Random" }
    public override var acronym: String { "RD" }
    public override var description: String { "It never gets boring!" }
    public override var type: ModType { .conversion }
}

public class ModReallyEasy: Mod {
    public override var name: String { "Really Easy" }
    public override var acronym: String { "RE" }
    public override var description: String { "Everything just got easier..." }
    public override var type: ModType { .difficultyReduction }
    public override var scoreMultiplier: Float { 0.5 }
}

public class ModRelax: Mod {
    public override var name: String { "Relax" }
    public override var acronym: String { "RX" }
    public override var description: String { "You don't need to tap. Give your tapping fingers a break from the heat of things." }
    public override var type: ModType { .automation }
    public override var scoreMultiplier: Float { 0.001 }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModAutopilot.self, ModAutoplay.self, ModNoFail.self] }
}

public class ModReplayV6: Mod {
    public override var name: String { "Replay V6" }
    public override var acronym: String { "RV6" }
    public override var description: String { "Applies the old object stacking behavior to a beatmap." }
    public override var type: ModType { .system }
    public override var isRanked: Bool { true }
    public override var isUserPlayable: Bool { false }
}

public class ModScoreV2: Mod {
    public override var name: String { "Score V2" }
    public override var acronym: String { "V2" }
    public override var description: String { "A different scoring mode from what you have known." }
    public override var type: ModType { .conversion }
    public override var isValidForMultiplayer: Bool { false }
    public override var isValidForMultiplayerAsFreeMod: Bool { false }
}

public class ModSmallCircle: Mod {
    public override var name: String { "Small Circle" }
    public override var acronym: String { "SC" }
    public override var description: String { "Who put ants in my beatmaps?" }
    public override var type: ModType { .difficultyIncrease }
}

public class ModSuddenDeath: Mod {
    public override var name: String { "Sudden Death" }
    public override var acronym: String { "SD" }
    public override var description: String { "Miss and fail." }
    public override var type: ModType { .difficultyIncrease }
    public override var isRanked: Bool { true }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModPerfect.self, ModNoFail.self, ModAutoplay.self] }
}

public class ModSynesthesia: Mod {
    public override var name: String { "Synesthesia" }
    public override var acronym: String { "SY" }
    public override var description: String { "Colors hit objects based on the rhythm." }
    public override var type: ModType { .fun }
    public override var scoreMultiplier: Float { 0.8 }
}

open class ModTimeRamp: Mod {
    public override var isValidForMultiplayerAsFreeMod: Bool { false }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModTimeRamp.self] }
}

public class ModTraceable: ModWithVisibilityAdjustment {
    public override var name: String { "Traceable" }
    public override var acronym: String { "TC" }
    public override var description: String { "Put your faith in the approach circles..." }
    public override var type: ModType { .difficultyIncrease }
    public override var scoreMultiplier: Float { 1.06 }
    public override var incompatibleMods: [AnyClass] { super.incompatibleMods + [ModHidden.self] }
}

public class ModWindDown: ModTimeRamp {
    public override var name: String { "Wind Down" }
    public override var acronym: String { "WD" }
    public override var description: String { "Sloooow doooown..." }
    public override var type: ModType { .fun }
}

public class ModWindUp: ModTimeRamp {
    public override var name: String { "Wind Up" }
    public override var acronym: String { "WU" }
    public override var description: String { "Can you keep up?" }
    public override var type: ModType { .fun }
}
