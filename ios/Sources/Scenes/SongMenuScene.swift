import SpriteKit

class SongMenuScene: SKScene {
    
    struct SongItem {
        let title: String
        let artist: String
        let difficulty: String
        let osuPath: String
        let audioPath: String
        let beatmap: PlayableBeatmap
    }
    
    private var songItems: [SongItem] = []
    private let scrollViewNode = SKNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "Select a Beatmap"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        addChild(titleLabel)
        
        addChild(scrollViewNode)
        
        loadSongs()
        createSongList()
    }
    
    private func loadSongs() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        let testBeatmapPath = (resourcePath as NSString).appendingPathComponent("TestBeatmap")
        
        let fm = FileManager.default
        let enumerator = fm.enumerator(atPath: testBeatmapPath)
        
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".osu") {
                let fullPath = (testBeatmapPath as NSString).appendingPathComponent(file)
                let parser = BeatmapParser(path: fullPath)
                if let beatmap = try? parser.parse(withHitObjects: true) {
                    
                    // Find audio path
                    let audioFileName = beatmap.general.audioFilename
                    let dirPath = (fullPath as NSString).deletingLastPathComponent
                    let audioPath = (dirPath as NSString).appendingPathComponent(audioFileName)
                    
                    let playable = beatmap.createDroidPlayableBeatmap()
                    let item = SongItem(
                        title: beatmap.metadata.title,
                        artist: beatmap.metadata.artist,
                        difficulty: beatmap.metadata.version,
                        osuPath: fullPath,
                        audioPath: audioPath,
                        beatmap: playable
                    )
                    songItems.append(item)
                }
            }
        }
    }
    
    private func createSongList() {
        if songItems.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "Helvetica")
            emptyLabel.text = "No beatmaps found in ios/Resources/TestBeatmap"
            emptyLabel.fontSize = 20
            emptyLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(emptyLabel)
            return
        }
        
        var yPos: CGFloat = size.height - 150
        
        for (index, item) in songItems.enumerated() {
            let container = SKNode()
            container.position = CGPoint(x: size.width / 2, y: yPos)
            container.name = "song_\(index)"
            
            let bg = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: 80), cornerRadius: 8)
            bg.fillColor = SKColor(white: 0.2, alpha: 0.8)
            bg.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)
            bg.name = "song_\(index)"
            container.addChild(bg)
            
            let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            titleLabel.text = "\(item.artist) - \(item.title)"
            titleLabel.fontSize = 24
            titleLabel.fontColor = .white
            titleLabel.verticalAlignmentMode = .bottom
            titleLabel.position = CGPoint(x: -bg.frame.width / 2 + 20, y: 5)
            titleLabel.name = "song_\(index)"
            container.addChild(titleLabel)
            
            let diffLabel = SKLabelNode(fontNamed: "Helvetica")
            diffLabel.text = "[\(item.difficulty)]"
            diffLabel.fontSize = 18
            diffLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
            diffLabel.verticalAlignmentMode = .top
            diffLabel.position = CGPoint(x: -bg.frame.width / 2 + 20, y: -5)
            diffLabel.name = "song_\(index)"
            container.addChild(diffLabel)
            
            scrollViewNode.addChild(container)
            yPos -= 100
        }
        
        // Add a back button
        let backContainer = SKNode()
        backContainer.position = CGPoint(x: 80, y: size.height - 40)
        backContainer.name = "backButton"
        
        let backBg = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 8)
        backBg.fillColor = .darkGray
        backBg.strokeColor = .clear
        backBg.name = "backButton"
        backContainer.addChild(backBg)
        
        let backLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 20
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backLabel.name = "backButton"
        backContainer.addChild(backLabel)
        
        addChild(backContainer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "backButton" {
                let mainMenu = MainMenuScene(size: size)
                mainMenu.scaleMode = .aspectFill
                let transition = SKTransition.push(with: .right, duration: 0.3)
                view?.presentScene(mainMenu, transition: transition)
                return
            }
            
            if let name = node.name, name.hasPrefix("song_") {
                let components = name.split(separator: "_")
                if components.count == 2, let index = Int(components[1]), index < songItems.count {
                    let item = songItems[index]
                    startGame(with: item)
                }
                return
            }
        }
    }
    
    private func startGame(with item: SongItem) {
        let gameplayScene = GameplayScene(beatmap: item.beatmap, audioPath: item.audioPath)
        gameplayScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameplayScene, transition: transition)
    }
}
