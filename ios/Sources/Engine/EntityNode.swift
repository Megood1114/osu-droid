import SpriteKit

/// Base node representing an AndEngine `Entity`.
/// Provides conveniences for applying modifiers and handling touch events.
class EntityNode: SKNode {
    
    // MARK: - Properties
    
    /// Replaces AndEngine's `setAlpha`
    var alphaModifier: CGFloat {
        get { self.alpha }
        set { self.alpha = max(0.0, min(1.0, newValue)) }
    }
    
    /// Replaces AndEngine's `setScale`
    func setScale(_ x: CGFloat, _ y: CGFloat) {
        self.xScale = x
        self.yScale = y
    }
    
    // MARK: - Modifiers (SKAction Wrappers)
    
    /// Replaces AndEngine's `AlphaModifier`
    func fade(to alpha: CGFloat, duration: TimeInterval) {
        let action = SKAction.fadeAlpha(to: alpha, duration: duration)
        self.run(action)
    }
    
    /// Replaces AndEngine's `ScaleModifier`
    func scale(to scale: CGFloat, duration: TimeInterval) {
        let action = SKAction.scale(to: scale, duration: duration)
        self.run(action)
    }
    
    /// Replaces AndEngine's `MoveModifier`
    func move(to position: CGPoint, duration: TimeInterval) {
        let action = SKAction.move(to: position, duration: duration)
        self.run(action)
    }
    
    /// Removes all modifiers (actions)
    func clearModifiers() {
        self.removeAllActions()
    }
    
    // MARK: - Hit Testing
    
    /// Replaces AndEngine's `contains(pX, pY)`
    override func contains(_ point: CGPoint) -> Bool {
        return self.calculateAccumulatedFrame().contains(point)
    }
    
    // MARK: - Lifecycle
    
    func onManagedUpdate(deltaTime: TimeInterval) {
        // Override in subclasses for per-frame updates
        for child in children {
            if let entity = child as? EntityNode {
                entity.onManagedUpdate(deltaTime: deltaTime)
            }
        }
    }
}
