import UIKit
import SpriteKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        // Create the SpriteKit view controller as root
        let gameViewController = GameViewController()
        window.rootViewController = gameViewController
        window.makeKeyAndVisible()

        self.window = window

        // Handle any URLs passed at launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }

    private func handleURL(_ url: URL) {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "osz":
            BeatmapImporter.shared.importBeatmapArchive(at: url)
        default:
            print("[osu!droid] Unhandled URL: \(url)")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume game engine when app becomes active
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause game engine when app goes to background
    }
}
