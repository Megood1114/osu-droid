import SpriteKit

/// Renders the body of a slider.
/// In AndEngine, this was done via 750 lines of software-side mesh triangulation.
/// In SpriteKit, we can leverage `SKShapeNode` and CoreGraphics to natively draw
/// thick, hardware-accelerated rounded line paths.
class SliderBodyNode: SKNode {
    
    private let backgroundNode = SKShapeNode()
    private let borderNode = SKShapeNode()
    private let hintNode = SKShapeNode()
    
    private var maxPathLength: Float = 0
    private var currentPoints: [CGPoint] = []
    
    override init() {
        super.init()
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        // Z-Position ordering: Hint (bottom) -> Border -> Background (top)
        hintNode.zPosition = -2
        borderNode.zPosition = -1
        backgroundNode.zPosition = 0
        
        // Ensure smooth rendering
        for node in [hintNode, borderNode, backgroundNode] {
            node.lineCap = .round
            node.lineJoin = .round
            node.isAntialiased = true
            addChild(node)
        }
        
        hintNode.isHidden = true
    }
    
    /// Initializes the slider body with the calculated path points.
    func initPath(points: [CGPoint], maxLength: Float) {
        self.currentPoints = points
        self.maxPathLength = maxLength
        
        let path = CGMutablePath()
        if !points.isEmpty {
            path.move(to: points[0])
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
        }
        
        backgroundNode.path = path
        borderNode.path = path
        hintNode.path = path
    }
    
    func setBackgroundWidth(_ width: CGFloat) {
        backgroundNode.lineWidth = width
    }
    
    func setBackgroundColor(_ color: UIColor) {
        backgroundNode.strokeColor = color
    }
    
    func setBorderWidth(_ width: CGFloat) {
        borderNode.lineWidth = width
    }
    
    func setBorderColor(_ color: UIColor) {
        borderNode.strokeColor = color
    }
    
    func setHintVisible(_ visible: Bool) {
        hintNode.isHidden = !visible
    }
    
    func setHintWidth(_ width: CGFloat) {
        hintNode.lineWidth = width
    }
    
    func setHintColor(_ color: UIColor) {
        hintNode.strokeColor = color
    }
    
    /// Replaces the complex 'cutPath' / 'fast path reuse' logic from Android.
    /// SpriteKit allows us to just supply a modified CGPath dynamically, or
    /// we can use an `SKCropNode` or `SKShader` for snake-in/snake-out animations.
    func updateVisibleLength(startLength: Float, endLength: Float) {
        // For standard slider follow, we just need to reconstruct the path
        // up to the current end length. CoreGraphics is highly optimized for this.
        
        guard !currentPoints.isEmpty else { return }
        
        // Simple fallback to drawing the full path if start=0 and end=max
        if startLength <= 0 && endLength >= maxPathLength {
            // Already handled by initPath
            return
        }
        
        // TODO: Implement exact path interpolation for "snaking" sliders
        // by calculating the exact point along the curve for startLength and endLength.
        // For MVP gameplay, full paths or simple interpolation is sufficient.
    }
}
