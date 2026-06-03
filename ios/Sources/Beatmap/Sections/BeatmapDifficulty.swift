import Foundation

/// Contains difficulty settings of a beatmap.
public class BeatmapDifficulty {
    /// The overall difficulty of this beatmap.
    public var od: Float

    /// The health drain rate of this beatmap.
    public var hp: Float

    /// The circle size of this beatmap in difficulty calculation.
    public var difficultyCS: Float

    /// The circle size of this beatmap in gameplay.
    public var gameplayCS: Float

    private var _ar: Float?
    /// The approach rate of this beatmap.
    public var ar: Float {
        get {
            if let ar = _ar, !ar.isNaN {
                return ar
            }
            return od
        }
        set {
            _ar = newValue
        }
    }

    /// The base slider velocity in hundreds of osu! pixels per beat.
    public var sliderMultiplier: Double = 1.0

    /// The amount of slider ticks per beat.
    public var sliderTickRate: Double = 1.0

    public init(cs: Float = 5.0, ar: Float? = nil, od: Float = 5.0, hp: Float = 5.0) {
        self.difficultyCS = cs
        self.gameplayCS = cs
        self._ar = ar ?? Float.nan
        self.od = od
        self.hp = hp
    }

    public func apply(_ other: BeatmapDifficulty) {
        self.difficultyCS = other.difficultyCS
        self.gameplayCS = other.gameplayCS
        self.ar = other.ar
        self.od = other.od
        self.hp = other.hp
        self.sliderMultiplier = other.sliderMultiplier
        self.sliderTickRate = other.sliderTickRate
    }

    public func copy() -> BeatmapDifficulty {
        let copy = BeatmapDifficulty(cs: self.difficultyCS, ar: self._ar, od: self.od, hp: self.hp)
        copy.gameplayCS = self.gameplayCS
        copy.sliderMultiplier = self.sliderMultiplier
        copy.sliderTickRate = self.sliderTickRate
        return copy
    }

    /// Maps a difficulty value [0, 10] to a two-piece linear range of values.
    public static func difficultyRange(difficulty: Double, min: Double, mid: Double, max: Double) -> Double {
        if difficulty > 5 {
            return mid + (max - mid) * (difficulty - 5) / 5
        } else if difficulty < 5 {
            return mid + (mid - min) * (difficulty - 5) / 5
        } else {
            return mid
        }
    }

    /// Maps a difficulty value [0, 10] to a two-piece linear range of values. Floors the value to `Int`.
    public static func difficultyRangeInt(difficulty: Double, min: Double, mid: Double, max: Double) -> Int {
        return Int(difficultyRange(difficulty: difficulty, min: min, mid: mid, max: max))
    }

    /// Inverse function to `difficultyRange`. Maps a value returned by the function back to the difficulty that produced it.
    public static func inverseDifficultyRange(difficultyValue: Double, diff0: Double, diff5: Double, diff10: Double) -> Double {
        let sign1 = (difficultyValue - diff5) > 0 ? 1 : ((difficultyValue - diff5) < 0 ? -1 : 0)
        let sign2 = (diff10 - diff0) > 0 ? 1 : ((diff10 - diff0) < 0 ? -1 : 0)
        
        if sign1 == sign2 {
            return (difficultyValue - diff5) / (diff10 - diff5) * 5 + 5
        } else {
            return (difficultyValue - diff5) / (diff5 - diff0) * 5 + 5
        }
    }
}
