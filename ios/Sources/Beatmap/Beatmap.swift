import Foundation

/// Represents a beatmap.
open class Beatmap: IBeatmap {
    /// The `GameMode` this `Beatmap` was parsed as.
    public private(set) var mode: GameMode
    
    public var formatVersion: Int = 14
    public var general: BeatmapGeneral = BeatmapGeneral()
    public var metadata: BeatmapMetadata = BeatmapMetadata()
    public var difficulty: BeatmapDifficulty = BeatmapDifficulty()
    public var events: BeatmapEvents = BeatmapEvents()
    public var colors: BeatmapColor = BeatmapColor()
    public var controlPoints: BeatmapControlPoints = BeatmapControlPoints()
    public var hitObjects: BeatmapHitObjects = BeatmapHitObjects()
    public var filePath: String = ""
    public var md5: String = ""
    
    public lazy var maxCombo: Int = {
        hitObjects.objects.reduce(0) { sum, obj in
            if let slider = obj as? Slider {
                return sum + slider.nestedHitObjects.count
            }
            return sum + 1
        }
    }()
    
    /// Initializes a new `Beatmap` with the specified `GameMode`.
    ///
    /// - Parameter mode: The `GameMode` this `Beatmap` was parsed as.
    public init(mode: GameMode) {
        self.mode = mode
    }
    
    /// Constructs a `DroidPlayableBeatmap` from this `Beatmap`, where all `HitObject` and `BeatmapDifficulty`
    /// `Mod`s have been applied, and `HitObject`s have been fully constructed.
    ///
    /// - Parameters:
    ///   - mods: The `Mod`s to apply to the `Beatmap`. Defaults to `nil`.
    /// - Returns: The `DroidPlayableBeatmap`.
    public func createDroidPlayableBeatmap(mods: [Mod]? = nil) -> DroidPlayableBeatmap {
        return DroidPlayableBeatmap(baseBeatmap: convert(mode: .droid, mods: mods), mods: mods)
    }
    
    /// Constructs a `StandardPlayableBeatmap` from this `Beatmap`, where all `HitObject` and `BeatmapDifficulty`
    /// `Mod`s have been applied, and `HitObject`s have been fully constructed.
    ///
    /// - Parameters:
    ///   - mods: The `Mod`s to apply to the `Beatmap`. Defaults to `nil`.
    /// - Returns: The `StandardPlayableBeatmap`.
    public func createStandardPlayableBeatmap(mods: [Mod]? = nil) -> StandardPlayableBeatmap {
        return StandardPlayableBeatmap(baseBeatmap: convert(mode: .standard, mods: mods), mods: mods)
    }
    
    /// Converts this `Beatmap` to another `Beatmap` for the specified `GameMode`, where all `HitObject` and
    /// `BeatmapDifficulty` `Mod`s have been applied, and `HitObject`s have been fully constructed.
    ///
    /// - Parameters:
    ///   - mode: The `GameMode` to convert the `Beatmap` to.
    ///   - mods: The `Mod`s to apply to the `Beatmap`. Defaults to `nil`.
    /// - Returns: The converted `Beatmap`.
    public func convert(mode: GameMode, mods: [Mod]? = nil) -> Beatmap {
        if self.mode == mode && (mods?.first == nil) {
            // Beatmap is already playable as is.
            return self
        }
        
        let adjustmentMods = mods?.compactMap { $0 as? IModFacilitatesAdjustment } ?? []
        
        mods?.compactMap { $0 as? IModRequiresBeatmapDifficulty }.forEach {
            $0.applyFromBeatmapDifficulty(difficulty)
        }
        
        let converter = BeatmapConverter(self)
        
        // Convert
        let converted = converter.convert()
        converted.mode = mode
        
        // Apply difficulty mods
        mods?.compactMap { $0 as? IModApplicableToDifficulty }.forEach {
            $0.applyToDifficulty(mode, converted.difficulty, adjustmentMods)
        }
        
        mods?.compactMap { $0 as? IModApplicableToDifficultyWithMods }.forEach {
            $0.applyToDifficulty(mode, converted.difficulty, mods ?? [])
        }
        
        let processor = BeatmapProcessor(converted)
        
        processor.preProcess()
        
        // Compute default values for hit objects, including creating nested hit objects in-case they're needed
        converted.hitObjects.objects.forEach {
            $0.applyDefaults(converted.controlPoints, converted.difficulty, mode)
        }
        
        mods?.compactMap { $0 as? IModApplicableToHitObject }.forEach { mod in
            for obj in converted.hitObjects.objects {
                mod.applyToHitObject(mode, obj, adjustmentMods)
            }
        }
        
        mods?.compactMap { $0 as? IModApplicableToHitObjectWithMods }.forEach { mod in
            for obj in converted.hitObjects.objects {
                mod.applyToHitObject(mode, obj, mods ?? [])
            }
        }
        
        processor.postProcess()
        
        mods?.compactMap { $0 as? IModApplicableToBeatmap }.forEach {
            $0.applyToBeatmap(converted)
        }
        
        return converted
    }
    
    /// Creates a clone of this `Beatmap`.
    public func clone() -> Beatmap {
        let copy = Beatmap(mode: self.mode)
        copy.formatVersion = self.formatVersion
        copy.general = self.general
        copy.metadata = self.metadata
        copy.difficulty = self.difficulty
        copy.events = self.events
        copy.colors = self.colors
        copy.controlPoints = self.controlPoints
        copy.hitObjects = self.hitObjects
        copy.filePath = self.filePath
        copy.md5 = self.md5
        return copy
    }
}
