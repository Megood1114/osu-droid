import SpriteKit

/// Initial splash screen shown on app launch.
/// Displays the osu!droid logo and transitions to the main menu.
class SplashScene: SKScene {

    private var logoNode: SKLabelNode!
    private var subtitleNode: SKLabelNode!

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)

        // osu! logo text (placeholder until we have the actual logo texture)
        logoNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        logoNode.text = "osu!droid"
        logoNode.fontSize = 72
        logoNode.fontColor = .white
        logoNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        logoNode.alpha = 0
        addChild(logoNode)

        // Subtitle
        subtitleNode = SKLabelNode(fontNamed: "Helvetica")
        subtitleNode.text = "iOS Port"
        subtitleNode.fontSize = 24
        subtitleNode.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0) // osu! pink
        subtitleNode.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        subtitleNode.alpha = 0
        addChild(subtitleNode)

        // Version label
        let versionNode = SKLabelNode(fontNamed: "Helvetica")
        versionNode.text = "v1.0.0-alpha"
        versionNode.fontSize = 14
        versionNode.fontColor = SKColor(white: 0.5, alpha: 1.0)
        versionNode.position = CGPoint(x: size.width / 2, y: 30)
        versionNode.alpha = 0
        addChild(versionNode)

        // Animate in
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        logoNode.setScale(0.8)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.8)
        scaleUp.timingMode = SKActionTimingMode.easeOut
        let appear = SKAction.group([fadeIn, scaleUp])

        logoNode.run(appear)
        subtitleNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            fadeIn
        ]))
        versionNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            fadeIn
        ]))

        // Transition to main menu after delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.run { [weak self] in
                self?.transitionToMainMenu()
            }
        ]))
    }

    private func transitionToMainMenu() {
        let mainMenu = MainMenuScene(size: size)
        mainMenu.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(mainMenu, transition: transition)
    }
}
