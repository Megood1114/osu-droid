import SpriteKit

/// Replaces AndEngine's `Camera`
/// Manages the viewport and coordinate conversions.
class Camera: SKCameraNode {
    
    private var viewportSize: CGSize
    
    init(viewportSize: CGSize) {
        self.viewportSize = viewportSize
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Converts a point from the scene's coordinate system to the camera's viewport coordinates.
    func sceneToCamera(_ point: CGPoint) -> CGPoint {
        return convert(point, from: self.parent ?? self)
    }
    
    /// Replaces AndEngine's HUD attachment.
    /// In SpriteKit, a HUD is just a node added directly to the Camera node so it stays fixed.
    func attachHUD(_ node: SKNode) {
        addChild(node)
    }
}
