import SpriteKit

/// Visual representation of a Slider.
class SliderNode: HitObjectNode {
    
    private let headCircle: HitCircleNode
    private let tailCircle: SKSpriteNode
    private let sliderBody: SliderBodyNode
    private let followCircle: SKSpriteNode
    
    let slider: Slider
    
    override init(hitObject: HitObject) {
        guard let slider = hitObject as? Slider else {
            fatalError("HitObject passed to SliderNode is not a Slider")
        }
        self.slider = slider
        
        let radius: CGFloat = 40.0
        
        // Setup Body
        sliderBody = SliderBodyNode()
        sliderBody.setBackgroundWidth(radius * 2)
        sliderBody.setBackgroundColor(UIColor(white: 0.2, alpha: 0.8))
        sliderBody.setBorderWidth(radius * 2 + 6)
        sliderBody.setBorderColor(UIColor.white)
        
        // Parse path into CGPoints
        var pathPoints: [CGPoint] = []
        for vec in slider.path.calculatedPath {
            // osu! Y coordinates are top-down. SpriteKit is bottom-up.
            // Since the parent node (playfield) handles the absolute inversion,
            // we might just need to supply relative or inverted coordinates here depending
            // on how we spawned it. For simplicity, assuming local space.
            pathPoints.append(CGPoint(x: Double(vec.x) - Double(slider.position.x),
                                      y: -(Double(vec.y) - Double(slider.position.y))))
        }
        sliderBody.initPath(points: pathPoints, maxLength: Float(slider.path.expectedDistance))
        
        // Setup Head (HitCircleNode automatically uses textures now)
        let fakeHead = HitCircle(
            startTime: slider.startTime,
            position: slider.position,
            isNewCombo: slider.isNewCombo,
            comboOffset: slider.comboOffset
        )
        headCircle = HitCircleNode(hitObject: fakeHead)
        
        // Setup Tail
        let circleTex = ResourceManager.shared.texture(named: "hitcircle")
        let overlayTex = ResourceManager.shared.texture(named: "hitcircleoverlay")
        
        tailCircle = SKSpriteNode(texture: circleTex)
        let tailOverlay = SKSpriteNode(texture: overlayTex)
        tailCircle.addChild(tailOverlay)
        
        if let last = pathPoints.last {
            tailCircle.position = last
        }
        
        // Setup Follow Circle
        let followTex = ResourceManager.shared.texture(named: "sliderfollowcircle")
        followCircle = SKSpriteNode(texture: followTex)
        followCircle.isHidden = true
        
        super.init(hitObject: hitObject)
        
        addChild(sliderBody)
        addChild(tailCircle)
        addChild(headCircle)
        addChild(followCircle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateApproach(preemptTime: Double) {
        headCircle.animateApproach(preemptTime: preemptTime)
    }
}
