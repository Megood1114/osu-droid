import SpriteKit
import UIKit

/// Manages loading and caching of game textures (Skins) and sounds.
class ResourceManager {
    static let shared = ResourceManager()
    
    private var textures: [String: SKTexture] = [:]
    
    private init() {}
    
    /// Returns the requested texture.
    /// It checks the custom skin path first, then falls back to the App Bundle.
    /// If completely missing, it generates a simple colored circle as a fallback.
    func texture(named name: String) -> SKTexture {
        // 1. Check cache
        if let tex = textures[name] {
            return tex
        }
        
        // 2. Check Custom Skin Directory (if enabled)
        if AppConfig.useCustomSkins {
            let customSkinURL = AppConfig.skinPath.appendingPathComponent("\(name).png")
            if let image = UIImage(contentsOfFile: customSkinURL.path) {
                let tex = SKTexture(image: image)
                textures[name] = tex
                return tex
            }
            
            // Check without .png just in case
            let customSkinURLFallback = AppConfig.skinPath.appendingPathComponent(name)
            if let image = UIImage(contentsOfFile: customSkinURLFallback.path) {
                let tex = SKTexture(image: image)
                textures[name] = tex
                return tex
            }
        }
        
        // 3. Check Main App Bundle
        if let image = UIImage(named: name) {
            let tex = SKTexture(image: image)
            textures[name] = tex
            return tex
        }
        
        // 4. Generate a fallback texture
        print("[ResourceManager] WARNING: Texture '\(name)' missing. Generating fallback.")
        let fallbackTex = generateFallbackTexture(for: name)
        textures[name] = fallbackTex
        return fallbackTex
    }
    
    /// Preloads common textures to prevent stuttering during gameplay.
    func preloadCommonTextures() {
        let common = ["hitcircle", "hitcircleoverlay", "approachcircle", "sliderb", "sliderfollowcircle", "spinner-background", "spinner-circle", "spinner-approachcircle"]
        for name in common {
            _ = texture(named: name)
        }
    }
    
    /// Clears the texture cache.
    func clearCache() {
        textures.removeAll()
    }
    
    // MARK: - Fallbacks
    
    private func generateFallbackTexture(for name: String) -> SKTexture {
        let size = CGSize(width: 128, height: 128)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return SKTexture() }
        
        let rect = CGRect(origin: .zero, size: size)
        
        // Draw something distinct based on the name
        if name.contains("approachcircle") {
            context.setStrokeColor(UIColor.cyan.cgColor)
            context.setLineWidth(6)
            context.strokeEllipse(in: rect.insetBy(dx: 6, dy: 6))
        } else if name.contains("overlay") {
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(4)
            context.strokeEllipse(in: rect.insetBy(dx: 4, dy: 4))
        } else if name.contains("hitcircle") {
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fillEllipse(in: rect)
        } else if name.contains("spinner") {
            context.setFillColor(UIColor.blue.withAlphaComponent(0.3).cgColor)
            context.fillEllipse(in: rect)
        } else {
            // Generic square
            context.setFillColor(UIColor.magenta.cgColor)
            context.fill(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
}
