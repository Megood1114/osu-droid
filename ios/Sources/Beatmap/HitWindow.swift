import Foundation

/// Represents a hit window.
/// Port of HitWindow.kt
class HitWindow {

    /// A fixed miss window regardless of difficulty settings in milliseconds.
    static let missWindow: Double = 400.0

    /// The overall difficulty of this hit window.
    var overallDifficulty: Double

    /// Creates a new HitWindow with the specified overall difficulty.
    ///
    /// - Parameter overallDifficulty: The overall difficulty. Defaults to 5.0.
    init(overallDifficulty: Double = 5.0) {
        self.overallDifficulty = overallDifficulty
    }

    /// The hit window for 300 (Great) hit result in milliseconds.
    var greatWindow: Double {
        fatalError("Subclasses must override greatWindow")
    }

    /// The hit window for 100 (OK) hit result in milliseconds.
    var okWindow: Double {
        fatalError("Subclasses must override okWindow")
    }

    /// The hit window for 50 (Meh) hit result in milliseconds.
    var mehWindow: Double {
        fatalError("Subclasses must override mehWindow")
    }
}

// MARK: - DroidHitWindow

/// Represents an osu!droid hit window.
/// Port of DroidHitWindow.kt
class DroidHitWindow: HitWindow {

    override var greatWindow: Double {
        return 75 + 5 * (5 - overallDifficulty)
    }

    override var okWindow: Double {
        return 150 + 10 * (5 - overallDifficulty)
    }

    override var mehWindow: Double {
        return 250 + 10 * (5 - overallDifficulty)
    }

    /// Calculates the overall difficulty value of a great hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow300ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 75) / 5
    }

    /// Calculates the overall difficulty value of an ok hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow100ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 150) / 10
    }

    /// Calculates the overall difficulty value of a meh hit window.
    ///
    /// - Parameter value: The value of the hit window in milliseconds.
    /// - Returns: The overall difficulty value.
    static func hitWindow50ToOverallDifficulty(_ value: Double) -> Double {
        return 5 - (value - 250) / 10
    }
}

// MARK: - StandardHitWindow

/// Represents the osu!standard hit window.
/// Port of StandardHitWindow.kt
class StandardHitWindow: HitWindow {

    override var greatWindow: Double {
        return floor(80 - 6 * overallDifficulty) - 0.5
    }

    override var okWindow: Double {
        return floor(140 - 8 * overallDifficulty) - 0.5
    }

    override var mehWindow: Double {
        return floor(200 - 10 * overallDifficulty) - 0.5
    }
}

// MARK: - EmptyHitWindow

/// An empty hit window with infinite timing windows.
/// Port of EmptyHitWindow.kt
class EmptyHitWindow: HitWindow {

    override var greatWindow: Double { return Double.infinity }
    override var okWindow: Double { return Double.infinity }
    override var mehWindow: Double { return Double.infinity }

    init() {
        super.init(overallDifficulty: 0)
    }
}
