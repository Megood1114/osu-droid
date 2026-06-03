import Foundation

/// A utility for converting circle sizes across game modes.
/// Port of CircleSizeCalculator.kt
enum CircleSizeCalculator {

    // MARK: - Constants

    /// These constants are used for scale calculations of replay version 6 and below.
    /// This was not the real height that is used in the game, but rather an assumption so that we can treat circle sizes
    /// similarly across all devices. This is used in difficulty calculation.
    private static let oldAssumedDroidHeight: Float = 681

    private static let oldDroidScaleMultiplier: Float = Float(0.5 * (11 - 5.2450170716245195) / 5)

    /// Builds of osu! up to 2013-05-04 had the gamefield being rounded down, which caused incorrect radius calculations
    /// in widescreen cases. This ratio adjusts to allow for old replays to work post-fix, which in turn increases the lenience
    /// for all plays, but by an amount so small it should only be effective in replays.
    ///
    /// To match expectations of gameplay we need to apply this multiplier to circle scale.
    private static let brokenGamefieldRoundingAllowance: Float = 1.00041

    /// The offset used to convert between osu!droid and osu!standard circle sizes.
    ///
    /// `6.8556344386` was derived by converting the old osu!droid gameplay scale unit into osu!pixels (by dividing it
    /// with (Config.RES_HEIGHT / 480)) and then fitting the function to the osu!standard scale function.
    private static let droidStandardCSOffset: Float = 6.855634

    // MARK: - Droid CS Conversions

    /// Converts osu!droid circle size to osu!droid scale.
    ///
    /// - Parameter cs: The circle size to convert.
    /// - Returns: The calculated osu!droid scale.
    static func droidCSToDroidScale(_ cs: Float) -> Float {
        return max(1e-3, standardCSToStandardScale(cs - droidStandardCSOffset, applyFudge: true))
    }

    /// Converts osu!droid circle size to osu!droid difficulty scale before replay version 7.
    ///
    /// - Parameter cs: The circle size to convert.
    /// - Returns: The calculated osu!droid difficulty scale in osu!pixels.
    static func droidCSToOldDroidDifficultyScale(_ cs: Float) -> Float {
        return max(1e-3, oldAssumedDroidHeight / 480 * (54.42 - cs * 4.48) / HitObject.objectRadius + oldDroidScaleMultiplier)
    }

    /// Converts osu!droid circle size to osu!droid gameplay scale before replay version 7.
    ///
    /// - Parameter cs: The circle size to convert.
    /// - Returns: The calculated osu!droid gameplay scale in osu!pixels.
    static func droidCSToOldDroidGameplayScale(_ cs: Float) -> Float {
        let resHeight = max(1, Float(AppConfig.renderHeight))
        return max(1e-3, (54.42 - cs * 4.48) / HitObject.objectRadius + oldDroidScaleMultiplier * 480 / resHeight)
    }

    /// Converts osu!droid scale to osu!droid circle size.
    ///
    /// - Parameter scale: The osu!droid scale to convert in osu!pixels.
    /// - Returns: The calculated osu!droid circle size.
    static func droidScaleToDroidCS(_ scale: Float) -> Float {
        return standardScaleToStandardCS(max(1e-3, scale), applyFudge: true) + droidStandardCSOffset
    }

    /// Converts osu!droid difficulty scale before replay version 7 to osu!droid circle size.
    ///
    /// - Parameter scale: The osu!droid scale to convert in osu!pixels.
    /// - Returns: The calculated osu!droid circle size.
    static func droidOldDifficultyScaleToDroidCS(_ scale: Float) -> Float {
        return (54.42 - (max(1e-3, scale) - oldDroidScaleMultiplier) * HitObject.objectRadius * 480 / oldAssumedDroidHeight) / 4.48
    }

    /// Converts osu!droid gameplay scale before replay version 7 to osu!droid circle size.
    ///
    /// - Parameter scale: The osu!droid scale to convert in osu!pixels.
    /// - Returns: The calculated osu!droid circle size.
    static func droidOldGameplayScaleToDroidCS(_ scale: Float) -> Float {
        let resHeight = max(1, Float(AppConfig.renderHeight))
        return (54.42 - (max(1e-3, scale) - oldDroidScaleMultiplier * 480 / resHeight) * HitObject.objectRadius) / 4.48
    }

    // MARK: - Old Scale Unit Conversions

    /// Converts old osu!droid difficulty scale that is in **screen pixels** to **osu!pixels**.
    static func droidOldDifficultyScaleScreenPixelsToOsuPixels(_ scale: Float) -> Float {
        return scale * 480 / oldAssumedDroidHeight
    }

    /// Converts old osu!droid difficulty scale that is in **osu!pixels** to **screen pixels**.
    static func droidOldDifficultyScaleOsuPixelsToScreenPixels(_ scale: Float) -> Float {
        return scale * oldAssumedDroidHeight / 480
    }

    /// Converts old osu!droid gameplay scale that is in **screen pixels** to **osu!pixels**.
    static func droidOldGameplayScaleScreenPixelsToOsuPixels(_ scale: Float) -> Float {
        let resHeight = max(1, Float(AppConfig.renderHeight))
        return scale * 480 / resHeight
    }

    /// Converts old osu!droid scale that is in **osu!pixels** to **screen pixels**.
    static func droidOldGameplayScaleOsuPixelsToScreenPixels(_ scale: Float) -> Float {
        let resHeight = max(1, Float(AppConfig.renderHeight))
        return scale * resHeight / 480
    }

    // MARK: - Cross-mode Conversions

    /// Converts osu!droid scale to osu!standard radius.
    ///
    /// - Parameter scale: The osu!droid scale to convert.
    /// - Returns: The osu!standard scale of the given radius.
    static func droidScaleToStandardRadius(_ scale: Float) -> Float {
        return Float(Double(HitObject.objectRadius) * Double(max(1e-3, scale)) / (Double(oldAssumedDroidHeight) * 0.85 / 384))
    }

    /// Converts osu!standard radius to osu!droid difficulty scale before replay version 7.
    ///
    /// - Parameter radius: The osu!standard radius to convert.
    /// - Returns: The osu!droid difficulty scale of the given osu!standard radius, in osu!pixels.
    static func standardRadiusToOldDroidDifficultyScale(_ radius: Double) -> Float {
        return Float(max(1e-3, radius * Double(oldAssumedDroidHeight) * 0.85 / 384 / Double(HitObject.objectRadius)))
    }

    /// Converts osu!standard radius to osu!standard circle size.
    ///
    /// - Parameters:
    ///   - radius: The osu!standard radius to convert.
    ///   - applyFudge: Whether to apply the broken gamefield rounding fudge.
    /// - Returns: The osu!standard circle size at the given radius.
    static func standardRadiusToStandardCS(_ radius: Double, applyFudge: Bool = false) -> Float {
        let fudge: Float = applyFudge ? brokenGamefieldRoundingAllowance : 1
        return 5 + (1 - Float(radius) / (HitObject.objectRadius / 2) / fudge) * 5 / 0.7
    }

    /// Converts osu!standard circle size to osu!standard scale.
    ///
    /// - Parameters:
    ///   - cs: The osu!standard circle size to convert.
    ///   - applyFudge: Whether to apply a fudge that was historically applied to osu!standard.
    /// - Returns: The osu!standard scale of the given circle size.
    static func standardCSToStandardScale(_ cs: Float, applyFudge: Bool = false) -> Float {
        let fudge: Float = applyFudge ? brokenGamefieldRoundingAllowance : 1
        return (1 - 0.7 * (cs - 5) / 5) / 2 * fudge
    }

    /// Converts osu!standard scale to osu!standard circle size.
    ///
    /// - Parameters:
    ///   - scale: The osu!standard scale to convert.
    ///   - applyFudge: Whether to apply a fudge that was historically applied to osu!standard.
    /// - Returns: The osu!standard circle size of the given osu!standard scale.
    static func standardScaleToStandardCS(_ scale: Float, applyFudge: Bool = false) -> Float {
        let fudge: Float = applyFudge ? brokenGamefieldRoundingAllowance : 1
        return 5 + 5 * (1 - 2 * scale / fudge) / 0.7
    }

    /// Converts osu!standard scale to osu!droid difficulty scale before replay version 7.
    ///
    /// - Parameters:
    ///   - scale: The osu!standard scale to convert.
    ///   - applyFudge: Whether to apply a fudge that was historically applied to osu!standard.
    /// - Returns: The osu!droid difficulty scale of the given osu!standard scale.
    static func standardScaleToOldDroidDifficultyScale(_ scale: Float, applyFudge: Bool = false) -> Float {
        let fudge: Float = applyFudge ? brokenGamefieldRoundingAllowance : 1
        return standardRadiusToOldDroidDifficultyScale(Double(HitObject.objectRadius) * Double(scale) / Double(fudge))
    }
}
