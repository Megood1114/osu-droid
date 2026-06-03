import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the main SKView
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        // Initialize our Game Engine
        GameEngine.shared.attach(to: skView)
        
        // Attempt to load a beatmap from the TestBeatmap folder
        loadTestBeatmap()
    }
    
    private func loadTestBeatmap() {
        // 1. Find the first .osu file in the app bundle
        guard let resourcePath = Bundle.main.resourcePath else {
            print("Failed to find bundle resource path.")
            showError("Failed to find bundle resource path.")
            return
        }
        
        // Since XcodeGen bundles the 'Resources' folder contents directly,
        // files in 'TestBeatmap' will be accessible via bundle paths.
        // We need to scan for an .osu file.
        let fm = FileManager.default
        let enumerator = fm.enumerator(atPath: resourcePath)
        
        var osuFilePath: String? = nil
        var audioFilePath: String? = nil
        
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".osu") {
                osuFilePath = (resourcePath as NSString).appendingPathComponent(file)
            } else if file.hasSuffix(".mp3") || file.hasSuffix(".ogg") {
                audioFilePath = (resourcePath as NSString).appendingPathComponent(file)
            }
        }
        
        guard let parsedOsuPath = osuFilePath else {
            print("No .osu file found in the app bundle.")
            showError("No .osu file found in TestBeatmap folder.\nPlease drop an .osu and .mp3 file into ios/Resources/TestBeatmap and recompile.")
            return
        }
        
        // 2. Parse the beatmap
        let parser = BeatmapParser()
        let beatmap = parser.parse(parsedOsuPath)
        
        guard let playableMap = beatmap else {
            showError("Failed to parse the .osu file.")
            return
        }
        
        // 3. Find the exact audio file mentioned in the beatmap if possible,
        // or just fallback to any audio file found in the folder.
        var finalAudioPath = audioFilePath
        if let audioFileName = playableMap.general.audioFilename {
            // Attempt to find the specific audio file
            let specificAudioPath = (resourcePath as NSString).appendingPathComponent("TestBeatmap/\(audioFileName)")
            if fm.fileExists(atPath: specificAudioPath) {
                finalAudioPath = specificAudioPath
            } else {
                // XcodeGen might flatten directories, so search root
                let flatPath = (resourcePath as NSString).appendingPathComponent(audioFileName)
                if fm.fileExists(atPath: flatPath) {
                    finalAudioPath = flatPath
                }
            }
        }
        
        guard let resolvedAudioPath = finalAudioPath else {
            showError("Found .osu but couldn't find the audio file.")
            return
        }
        
        // 4. Start the GameplayScene!
        let gameplayScene = GameplayScene(beatmap: playableMap, audioPath: resolvedAudioPath)
        GameEngine.shared.setScene(gameplayScene)
    }
    
    private func showError(_ message: String) {
        let label = UILabel(frame: view.bounds)
        label.text = message
        label.textColor = .red
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(label)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
