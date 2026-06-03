import Foundation

public final class Island: Hashable, Equatable {
    private let deltaDifferenceEpsilon: Double
    
    public private(set) var delta: Int = Int.max
    public private(set) var deltaCount: Int = 0
    
    init(epsilon: Double) {
        self.deltaDifferenceEpsilon = epsilon
    }
    
    init(delta: Int, deltaDifferenceEpsilon: Double) {
        self.deltaDifferenceEpsilon = deltaDifferenceEpsilon
        self.addDelta(delta: delta)
    }
    
    func addDelta(delta: Int) {
        if self.delta == Int.max {
            self.delta = max(delta, Int(DifficultyHitObject.minDeltaTime))
        }
        
        self.deltaCount += 1
    }
    
    func isSimilarPolarity(other: Island) -> Bool {
        return self.deltaCount % 2 == other.deltaCount % 2
    }
    
    public static func == (lhs: Island, rhs: Island) -> Bool {
        if lhs === rhs {
            return true
        }
        
        return abs(Double(lhs.delta - rhs.delta)) < lhs.deltaDifferenceEpsilon && lhs.deltaCount == rhs.deltaCount
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(delta)
        hasher.combine(deltaCount)
    }
}
