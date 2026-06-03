import SpriteKit

/// Base scene class replacing AndEngine's `Scene`.
/// Integrates with our GameEngine and provides a managed update loop.
class GameScene: SKScene {
    
    private var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }
    
    /// Override this to perform setup when the scene is presented.
    func setupScene() {
        // Default implementation does nothing.
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Propagate managed update down the EntityNode tree
        for child in children {
            if let entity = child as? EntityNode {
                entity.onManagedUpdate(deltaTime: dt)
            }
        }
        
        onManagedUpdate(deltaTime: dt)
    }
    
    /// Override this to perform per-frame updates.
    /// Replaces AndEngine's `IUpdateHandler.onUpdate()`.
    func onManagedUpdate(deltaTime: TimeInterval) {
        // Default implementation does nothing.
    }
}
