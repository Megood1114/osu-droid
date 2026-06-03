import SpriteKit

/// Master controller replacing AndEngine's `Engine`.
/// Manages the `SKView` and scene transitions.
class GameEngine {
    
    static let shared = GameEngine()
    
    private(set) weak var skView: SKView?
    private(set) var currentScene: SKScene?
    
    private init() {}
    
    /// Initializes the engine with the root SKView.
    func attach(to view: SKView) {
        self.skView = view
        
        // Configure SKView for optimal 2D performance
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsDrawCount = true
        view.showsNodeCount = true
        
        // Use Metal as the rendering backend
        view.preferredFramesPerSecond = 60
    }
    
    /// Replaces AndEngine's `Engine.setScene()`
    func setScene(_ scene: SKScene, transition: SKTransition? = nil) {
        guard let view = skView else {
            print("Error: GameEngine is not attached to an SKView.")
            return
        }
        
        // Standardize scene configuration
        scene.scaleMode = .aspectFill
        
        if let transition = transition {
            view.presentScene(scene, transition: transition)
        } else {
            view.presentScene(scene)
        }
        
        self.currentScene = scene
    }
}
