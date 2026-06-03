import Foundation

/// Converts a `Beatmap` for another `GameMode`.
public class BeatmapConverter {
    /// The `Beatmap` to convert.
    public let beatmap: Beatmap

    public init(beatmap: Beatmap) {
        self.beatmap = beatmap
    }

    /// Converts `Beatmap`.
    ///
    /// - Returns: The converted `Beatmap`.
    public func convert() -> Beatmap {
        let newBeatmap = beatmap.clone()
        
        // Shallow clone isn't enough to ensure we don't mutate some beatmap properties unexpectedly.
        newBeatmap.difficulty = beatmap.difficulty.copy()
        
        let convertedHitObjects = convertHitObjects()
        convertedHitObjects.objects.sort { $0.startTime < $1.startTime }
        newBeatmap.hitObjects = convertedHitObjects
        
        return newBeatmap
    }

    private func convertHitObjects() -> BeatmapHitObjects {
        let newHitObjects = BeatmapHitObjects()
        for obj in beatmap.hitObjects.objects {
            newHitObjects.add(convertHitObject(obj))
        }
        return newHitObjects
    }

    private func convertHitObject(_ hitObject: HitObject) -> HitObject {
        let newHitObject: HitObject
        
        if let hitCircle = hitObject as? HitCircle {
            newHitObject = HitCircle(
                startTime: hitCircle.startTime,
                position: hitCircle.position,
                isNewCombo: hitCircle.isNewCombo,
                comboOffset: hitCircle.comboOffset
            )
        } else if let slider = hitObject as? Slider {
            let newSlider = Slider(
                startTime: slider.startTime,
                position: slider.position,
                repeatCount: slider.repeatCount,
                path: slider.path,
                isNewCombo: slider.isNewCombo,
                comboOffset: slider.comboOffset,
                nodeSamples: slider.nodeSamples
            )
            
            // Prior to v8, speed multipliers don't adjust for how many ticks are generated over the same distance.
            // This results in more (or less) ticks being generated in <v8 maps for the same time duration.
            newSlider.tickDistanceMultiplier = beatmap.formatVersion < 8 
                ? 1.0 / beatmap.controlPoints.difficulty.controlPointAt(newSlider.startTime).speedMultiplier 
                : 1.0
            newSlider.generateTicks = slider.generateTicks
            
            newHitObject = newSlider
        } else if let spinner = hitObject as? Spinner {
            newHitObject = Spinner(
                startTime: spinner.startTime,
                endTime: spinner.endTime,
                isNewCombo: spinner.isNewCombo
            )
        } else {
            fatalError("Invalid type of hit object")
        }
        
        newHitObject.samples = hitObject.samples
        newHitObject.auxiliarySamples = hitObject.auxiliarySamples
        
        return newHitObject
    }
}
