import SpriteKit

/// The main gameplay scene that renders the beatmap, manages audio sync,
/// and processes hit judgements.
class GameplayScene: GameScene {
    
    // MARK: - Properties
    
    let beatmap: PlayableBeatmap
    let scoreProcessor: ScoreProcessor
    let songService: SongService
    
    // Nodes
    private let playfieldNode = SKNode()
    private let uiNode = SKNode()
    private let comboLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private let accuracyLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    
    // Playback state
    private var isPlaying: Bool = false
    private var objectIndex: Int = 0
    private var activeObjects: [HitObject] = []
    
    // Pre-calculated timing windows
    private let hitWindow300: Double
    private let hitWindow100: Double
    private let hitWindow50: Double
    private let preemptTime: Double
    
    // MARK: - Initialization
    
    init(beatmap: PlayableBeatmap, audioPath: String) {
        self.beatmap = beatmap
        self.scoreProcessor = ScoreProcessor(totalObjects: beatmap.hitObjects.objects.count)
        self.songService = SongService()
        
        // Calculate AR and OD preempt/hit windows based on beatmap difficulty
        let ar = beatmap.difficulty.ar
        let od = beatmap.difficulty.od
        
        // standard preempt calculation
        self.preemptTime = ar > 5 
            ? 1200 - 150 * Double(ar - 5) 
            : 1200 + 120 * Double(5 - ar)
            
        // OD window calculations (Standard osu! scaling)
        self.hitWindow300 = 80 - 6 * Double(od)
        self.hitWindow100 = 140 - 8 * Double(od)
        self.hitWindow50 = 200 - 10 * Double(od)
        
        super.init(size: CGSize(width: 1024, height: 768)) // default size, scaled by Engine
        
        // Load Audio
        _ = songService.preLoad(filePath: audioPath, speed: 1.0, adjustPitch: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupScene() {
        self.backgroundColor = .black
        
        // 1. Setup Playfield (centered, fixed aspect ratio 4:3)
        // osu! coordinates are 512x384. We scale this to fill the height, keeping 4:3.
        let scale = self.size.height / 384.0
        playfieldNode.setScale(scale)
        playfieldNode.position = CGPoint(
            x: (self.size.width - (512.0 * scale)) / 2.0,
            y: 0 // bottom aligned, or center depending on preference
        )
        addChild(playfieldNode)
        
        // 2. Setup HUD
        setupHUD()
        addChild(uiNode)
        
        // 3. Start Game
        startGame()
    }
    
    private func setupHUD() {
        comboLabel.text = "0x"
        comboLabel.fontSize = 48
        comboLabel.fontColor = .white
        comboLabel.position = CGPoint(x: 50, y: 50)
        comboLabel.horizontalAlignmentMode = .left
        uiNode.addChild(comboLabel)
        
        accuracyLabel.text = "100.00%"
        accuracyLabel.fontSize = 32
        accuracyLabel.fontColor = .white
        accuracyLabel.position = CGPoint(x: self.size.width - 50, y: 50)
        accuracyLabel.horizontalAlignmentMode = .right
        uiNode.addChild(accuracyLabel)
        
        scoreLabel.text = "0000000"
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.size.width - 50, y: self.size.height - 50)
        scoreLabel.horizontalAlignmentMode = .right
        uiNode.addChild(scoreLabel)
    }
    
    // MARK: - Game Loop
    
    private func startGame() {
        isPlaying = true
        songService.play()
    }
    
    override func onManagedUpdate(deltaTime: TimeInterval) {
        guard isPlaying else { return }
        
        let currentTime = songService.position // In milliseconds
        
        // 1. Spawn objects that enter the preempt window
        while objectIndex < beatmap.hitObjects.objects.count {
            let obj = beatmap.hitObjects.objects[objectIndex]
            if currentTime >= (obj.startTime - preemptTime) {
                spawnHitObject(obj)
                objectIndex += 1
            } else {
                break
            }
        }
        
        // 2. Update HUD
        updateHUD()
    }
    
    // MARK: - Spawning
    
    private func spawnHitObject(_ obj: HitObject) {
        // Note: osu! Y coordinates are top-down (0 = top, 384 = bottom).
        // SpriteKit is bottom-up. We must invert Y.
        let convertedPosition = CGPoint(
            x: Double(obj.position.x),
            y: 384.0 - Double(obj.position.y)
        )
        
        let node: HitObjectNode
        
        if let circle = obj as? HitCircle {
            let circleNode = HitCircleNode(hitObject: circle)
            circleNode.animateApproach(preemptTime: preemptTime)
            node = circleNode
        } else if let slider = obj as? Slider {
            let sliderNode = SliderNode(hitObject: slider)
            sliderNode.animateApproach(preemptTime: preemptTime)
            node = sliderNode
        } else if let spinner = obj as? Spinner {
            let spinnerNode = SpinnerNode(hitObject: spinner)
            let duration = spinner.endTime - spinner.startTime
            spinnerNode.animate(duration: duration)
            node = spinnerNode
        } else {
            // Fallback for unknown types
            node = HitObjectNode(hitObject: obj)
        }
        
        node.position = convertedPosition
        node.alpha = 0
        playfieldNode.addChild(node)
        
        // Animations: Fade in -> Wait -> Fade out
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: preemptTime / 3000.0) // fraction of preempt
        let wait = SKAction.wait(forDuration: preemptTime / 1000.0) // wait until exact start time
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        let remove = SKAction.removeFromParent()
        
        node.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        activeObjects.append(obj)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlaying else { return }
        
        let currentTime = songService.position
        
        for touch in touches {
            let location = touch.location(in: playfieldNode)
            
            // Iterate over active objects (oldest first)
            for node in playfieldNode.children {
                guard let hitNode = node as? HitObjectNode else { continue }
                
                // Only process objects within a valid hit window (e.g. 50 window)
                let timeDiff = abs(currentTime - hitNode.hitObject.startTime)
                if timeDiff <= hitWindow50 {
                    if let result = hitNode.handleTouch(location, time: currentTime, hitWindow50: hitWindow50, hitWindow100: hitWindow100, hitWindow300: hitWindow300) {
                        
                        scoreProcessor.addHit(result: result)
                        showHitResult(result, at: hitNode.position)
                        
                        // Object is hit, remove it
                        hitNode.removeFromParent()
                        break // One touch per object
                    }
                }
            }
        }
    }
    
    private func showHitResult(_ result: HitResult, at position: CGPoint) {
        // Simple label for hit result
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = result == .miss ? "X" : "\(result.rawValue)"
        label.fontSize = 30
        label.fontColor = result == .great ? .cyan : (result == .good ? .green : (result == .meh ? .orange : .red))
        label.position = position
        label.zPosition = 10
        playfieldNode.addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.sequence([group, remove]))
    }
    
    // MARK: - HUD Updates
    
    private func updateHUD() {
        comboLabel.text = "\(scoreProcessor.currentCombo)x"
        accuracyLabel.text = String(format: "%.2f%%", scoreProcessor.accuracy * 100)
        scoreLabel.text = String(format: "%07d", scoreProcessor.totalScore)
    }
}
