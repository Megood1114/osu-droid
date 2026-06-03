import Foundation

/// Represents a precise osu!droid hit window.
/// Used when the Precise (PR) mod is active.
/// Port of PreciseDroidHitWindow.kt
class PreciseDroidHitWindow: HitWindow {

    override var greatWindow: Double {
        return 55 + 6 * (5 - overallDifficulty)
    }

    override var okWindow: Double {
        return 120 + 8 * (5 - overallDifficulty)
    }

    override var mehWindow: Double {
        return 200 + 10 * (5 - overallDifficulty)
    }

    /// Calculates the overall difficulty value of a great hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow300ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 55) / 6
    }

    /// Calculates the overall difficulty value of an ok hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow100ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 120) / 8
    }

    /// Calculates the overall difficulty value of a meh hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow50ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 200) / 10
    }
}
