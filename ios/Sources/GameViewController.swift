import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the main SKView
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        // Initialize our Game Engine
        GameEngine.shared.attach(to: skView)
        
        // Launch the initial scene
        let splashScene = SplashScene(size: skView.bounds.size)
        splashScene.scaleMode = .aspectFill
        GameEngine.shared.setScene(splashScene)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
