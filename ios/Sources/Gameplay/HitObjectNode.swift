import SpriteKit

/// Base class for hit object nodes in the gameplay scene.
class HitObjectNode: EntityNode {
    let hitObject: HitObject
    
    init(hitObject: HitObject) {
        self.hitObject = hitObject
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Called when the object is clicked/tapped.
    func handleTouch(_ location: CGPoint, time: Double, hitWindow50: Double, hitWindow100: Double, hitWindow300: Double) -> HitResult? {
        // Base implementation does nothing
        return nil
    }
}

/// Visual representation of a HitCircle.
class HitCircleNode: HitObjectNode {
    
    private let circleNode: SKSpriteNode
    private let approachCircle: SKSpriteNode
    private let overlayNode: SKSpriteNode
    
    // Default osu!droid scale/radius
    private let radius: CGFloat = 64.0 // Standard texture size base
    
    override init(hitObject: HitObject) {
        
        let circleTex = ResourceManager.shared.texture(named: "hitcircle")
        let overlayTex = ResourceManager.shared.texture(named: "hitcircleoverlay")
        let approachTex = ResourceManager.shared.texture(named: "approachcircle")
        
        circleNode = SKSpriteNode(texture: circleTex)
        // Fallback coloring if the texture is a template, usually skins are colored via combo
        circleNode.color = .white // Default combo color
        circleNode.colorBlendFactor = 1.0
        
        overlayNode = SKSpriteNode(texture: overlayTex)
        
        approachCircle = SKSpriteNode(texture: approachTex)
        // Approach circles are tinted with the combo color
        approachCircle.color = .white
        approachCircle.colorBlendFactor = 1.0
        
        super.init(hitObject: hitObject)
        
        // Z-Ordering
        circleNode.zPosition = 1
        overlayNode.zPosition = 2
        approachCircle.zPosition = 3
        
        addChild(circleNode)
        addChild(overlayNode)
        addChild(approachCircle)
    }
    
    override func handleTouch(_ location: CGPoint, time: Double, hitWindow50: Double, hitWindow100: Double, hitWindow300: Double) -> HitResult? {
        // 1. Check spatial distance
        let dx = location.x - self.position.x
        let dy = location.y - self.position.y
        let distanceSquared = dx*dx + dy*dy
        
        // Allow slightly larger hit area for fingers
        if distanceSquared > (radius * radius * 1.5) {
            return nil
        }
        
        // 2. Check timing window
        let timeDiff = abs(time - hitObject.startTime)
        
        if timeDiff <= hitWindow300 {
            return .great
        } else if timeDiff <= hitWindow100 {
            return .good
        } else if timeDiff <= hitWindow50 {
            return .meh
        }
        
        // Note: Missing is handled by the GameplayScene if time passes hitWindow50 without a tap.
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Starts the approach circle animation.
    func animateApproach(preemptTime: Double) {
        approachCircle.setScale(3.0)
        approachCircle.alpha = 0
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: preemptTime / 3000.0) // initial fade
        let scaleDown = SKAction.scale(to: 1.0, duration: preemptTime / 1000.0) // scale over full preempt
        
        approachCircle.run(SKAction.group([fadeIn, scaleDown]))
    }
}
