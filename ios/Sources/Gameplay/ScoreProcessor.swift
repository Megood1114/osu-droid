import Foundation

/// Defines the possible hit results for an object.
enum HitResult: Int {
    case great = 300
    case good = 100
    case meh = 50
    case miss = 0
}

/// Processes score, combo, and accuracy during gameplay.
class ScoreProcessor {
    
    // MARK: - Properties
    
    private(set) var totalScore: Int = 0
    private(set) var currentCombo: Int = 0
    private(set) var maxCombo: Int = 0
    private(set) var accuracy: Double = 1.0
    
    // Hit counts
    private(set) var count300: Int = 0
    private(set) var count100: Int = 0
    private(set) var count50: Int = 0
    private(set) var countMiss: Int = 0
    
    // Total objects in the map
    private let totalObjects: Int
    
    // Multipliers
    private let difficultyMultiplier: Double
    private let modMultiplier: Double
    
    // MARK: - Initialization
    
    init(totalObjects: Int, difficultyMultiplier: Double = 1.0, modMultiplier: Double = 1.0) {
        self.totalObjects = totalObjects
        self.difficultyMultiplier = difficultyMultiplier
        self.modMultiplier = modMultiplier
    }
    
    // MARK: - Processing
    
    /// Registers a hit result for an object.
    func addHit(result: HitResult) {
        // 1. Update hit counts
        switch result {
        case .great: count300 += 1
        case .good: count100 += 1
        case .meh: count50 += 1
        case .miss: countMiss += 1
        }
        
        // 2. Update combo
        if result == .miss {
            currentCombo = 0
        } else {
            currentCombo += 1
            maxCombo = max(maxCombo, currentCombo)
        }
        
        // 3. Update score
        if result != .miss {
            let baseScore = Double(result.rawValue)
            let comboBonus = max(1.0, Double(currentCombo - 1))
            let scoreAdd = baseScore + (baseScore * comboBonus * difficultyMultiplier * modMultiplier) / 25.0
            totalScore += Int(scoreAdd)
        }
        
        // 4. Update accuracy
        updateAccuracy()
    }
    
    /// Reverts a hit (useful for rewind/scrubbing).
    func revertHit(result: HitResult) {
        // Note: Reverting combo exactly is complex without history,
        // this is a simplified version.
        switch result {
        case .great: count300 = max(0, count300 - 1)
        case .good: count100 = max(0, count100 - 1)
        case .meh: count50 = max(0, count50 - 1)
        case .miss: countMiss = max(0, countMiss - 1)
        }
        
        updateAccuracy()
    }
    
    private func updateAccuracy() {
        let totalHits = count300 + count100 + count50 + countMiss
        guard totalHits > 0 else {
            accuracy = 1.0
            return
        }
        
        let totalScorePossible = totalHits * 300
        let actualScore = (count300 * 300) + (count100 * 100) + (count50 * 50)
        
        accuracy = Double(actualScore) / Double(totalScorePossible)
    }
    
    /// Resets the processor to its initial state.
    func reset() {
        totalScore = 0
        currentCombo = 0
        maxCombo = 0
        accuracy = 1.0
        count300 = 0
        count100 = 0
        count50 = 0
        countMiss = 0
    }
}
