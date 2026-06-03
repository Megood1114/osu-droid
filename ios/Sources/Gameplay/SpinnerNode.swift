import SpriteKit

/// Visual representation of a Spinner.
class SpinnerNode: HitObjectNode {
    
    private let spinnerCircle: SKSpriteNode
    private let approachCircle: SKSpriteNode
    
    let spinner: Spinner
    
    override init(hitObject: HitObject) {
        guard let spinner = hitObject as? Spinner else {
            fatalError("HitObject passed to SpinnerNode is not a Spinner")
        }
        self.spinner = spinner
        
        // The spinner usually takes up the entire playfield height
        let radius: CGFloat = 150.0
        
        // In a real skin, this would be a textured SKSpriteNode
        let bgTex = ResourceManager.shared.texture(named: "spinner-background")
        spinnerCircle = SKSpriteNode(texture: bgTex)
        spinnerCircle.size = CGSize(width: radius * 2, height: radius * 2)
        spinnerCircle.alpha = 0.5
        
        let approachTex = ResourceManager.shared.texture(named: "spinner-approachcircle")
        approachCircle = SKSpriteNode(texture: approachTex)
        approachCircle.size = CGSize(width: radius * 3, height: radius * 3)
        
        super.init(hitObject: hitObject)
        
        // Spinners are always centered in osu! coordinates (256, 192)
        // Parent gameplay scene handles position.
        
        addChild(spinnerCircle)
        addChild(approachCircle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Animates the spinner entering and the approach circle closing
    func animate(duration: Double) {
        let spin = SKAction.rotate(byAngle: -.pi * 4, duration: duration)
        spinnerCircle.run(spin)
        
        approachCircle.setScale(1.0)
        let scaleDown = SKAction.scale(to: 0.1, duration: duration)
        approachCircle.run(scaleDown)
    }
}
