import SpriteKit

/// Main menu scene — the hub for navigation.
/// Port of MainScene.java.
class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.06, blue: 0.15, alpha: 1.0)

        // Placeholder main menu — will be fully implemented in Phase 5
        let titleNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleNode.text = "osu!droid"
        titleNode.fontSize = 48
        titleNode.fontColor = .white
        titleNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 60)
        addChild(titleNode)

        let playButton = createMenuButton(
            text: "Play",
            position: CGPoint(x: size.width / 2, y: size.height / 2 - 20),
            name: "playButton"
        )
        addChild(playButton)

        let settingsButton = createMenuButton(
            text: "Settings",
            position: CGPoint(x: size.width / 2, y: size.height / 2 - 80),
            name: "settingsButton"
        )
        addChild(settingsButton)
    }

    private func createMenuButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 250, height: 50), cornerRadius: 12)
        bg.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 0.8)
        bg.strokeColor = .clear
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            if node.name == "playButton" || node.parent?.name == "playButton" {
                let songMenu = SongMenuScene(size: size)
                songMenu.scaleMode = .aspectFill
                let transition = SKTransition.push(with: .left, duration: 0.3)
                view?.presentScene(songMenu, transition: transition)
                return
            }
        }
    }
}
