import Foundation

/// Game constants for playfield dimensions and layout.
enum GameConstants {
    /// The width of the osu! playfield in osu!pixels.
    static let mapWidth: Int = 512

    /// The height of the osu! playfield in osu!pixels.
    static let mapHeight: Int = 384

    /// The old actual width of the playfield on screen.
    static let mapActualWidthOld: Int = 820

    /// The old actual height of the playfield on screen.
    static let mapActualHeightOld: Int = 570

    /// The actual height of the playfield on screen, based on render resolution.
    static var mapActualHeight: Float {
        Float(AppConfig.renderHeight) * 0.8
    }

    /// The actual width of the playfield on screen (4:3 aspect ratio based on height).
    static var mapActualWidth: Float {
        Float(Int(mapActualHeight) / 3 * 4)
    }
}
