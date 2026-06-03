import Foundation
import UIKit

/// A simple RGBA color representation.
/// Port of Color4 from com/reco1l/framework/ColorComponent.kt
struct Color4: Equatable, Hashable {

    /// Red component (0.0 to 1.0)
    var r: Float

    /// Green component (0.0 to 1.0)
    var g: Float

    /// Blue component (0.0 to 1.0)
    var b: Float

    /// Alpha component (0.0 to 1.0)
    var a: Float

    /// Creates a color with RGBA components (0.0 to 1.0).
    init(r: Float = 0, g: Float = 0, b: Float = 0, a: Float = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    /// Creates a color from integer RGB values (0 to 255).
    init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.r = Float(r) / 255.0
        self.g = Float(g) / 255.0
        self.b = Float(b) / 255.0
        self.a = Float(a) / 255.0
    }

    /// Creates a color from a hex integer (e.g., 0xFF6699).
    init(hex: Int, alpha: Float = 1.0) {
        self.r = Float((hex >> 16) & 0xFF) / 255.0
        self.g = Float((hex >> 8) & 0xFF) / 255.0
        self.b = Float(hex & 0xFF) / 255.0
        self.a = alpha
    }

    /// Creates a Color4 from a UIColor.
    init(uiColor: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.r = Float(r)
        self.g = Float(g)
        self.b = Float(b)
        self.a = Float(a)
    }

    // MARK: - Preset Colors

    static let white = Color4(r: 1, g: 1, b: 1, a: 1)
    static let black = Color4(r: 0, g: 0, b: 0, a: 1)
    static let clear = Color4(r: 0, g: 0, b: 0, a: 0)
    static let red = Color4(r: 1, g: 0, b: 0, a: 1)
    static let green = Color4(r: 0, g: 1, b: 0, a: 1)
    static let blue = Color4(r: 0, g: 0, b: 1, a: 1)

    // MARK: - Conversions

    /// Convert to UIColor.
    var uiColor: UIColor {
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }

    /// Convert to SKColor (alias for UIColor on iOS).
    var skColor: UIColor {
        return uiColor
    }

    // MARK: - Operations

    /// Returns a new color with the specified alpha.
    func withAlpha(_ alpha: Float) -> Color4 {
        return Color4(r: r, g: g, b: b, a: alpha)
    }

    /// Linearly interpolate between this color and another.
    func lerp(to other: Color4, amount: Float) -> Color4 {
        return Color4(
            r: r + (other.r - r) * amount,
            g: g + (other.g - g) * amount,
            b: b + (other.b - b) * amount,
            a: a + (other.a - a) * amount
        )
    }
}
