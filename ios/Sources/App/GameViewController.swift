import UIKit
import SpriteKit

/// Root view controller that hosts the SpriteKit game view.
/// Equivalent to Android's MainActivity + BaseGameActivity.
class GameViewController: UIViewController {

    /// The SpriteKit view that renders all game content.
    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create and configure the SKView
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true // Better performance for SpriteKit

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        #endif

        view.addSubview(skView)

        // Present the splash scene
        let splashScene = SplashScene(size: skView.bounds.size)
        splashScene.scaleMode = .aspectFill
        skView.presentScene(splashScene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true // Hide home indicator during gameplay
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all // Defer system gestures so they don't interrupt gameplay
    }
}
