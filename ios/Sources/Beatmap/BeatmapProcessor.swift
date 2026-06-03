import Foundation

/// Provides functionality to alter an `IBeatmap` after it has been converted.
class BeatmapProcessor {
    private static let stackDistance: Int = 3
    private static let stackDistanceSquared: Float = Float(stackDistance * stackDistance)

    /// The `IBeatmap` to process. This should already be converted to the applicable mode.
    let beatmap: IBeatmap

    init(beatmap: IBeatmap) {
        self.beatmap = beatmap
    }

    /// Processes the converted `IBeatmap` prior to `HitObject.applyDefaults` being invoked.
    ///
    /// Nested `HitObject`s generated during `HitObject.applyDefaults` will not be present by this point,
    /// and no `Mod`s will have been applied to the `HitObject`s.
    ///
    /// This can only be used to add alterations to `HitObject`s generated directly through the conversion process.
    func preProcess() {
        var lastObj: HitObject? = nil

        for obj in beatmap.hitObjects.objects {
            obj.updateComboInformation(lastObj: lastObj)
            lastObj = obj
        }

        // Mark the last object in the beatmap as last in combo.
        if let lastObj = lastObj {
            lastObj.isLastInCombo = true
        }
    }

    /// Processes the converted `IBeatmap` after `HitObject.applyDefaults` has been invoked.
    ///
    /// Nested `HitObject`s generated during `HitObject.applyDefaults` will be present by this point,
    /// and `Mod`s will have been applied to all `HitObject`s.
    ///
    /// This should be used to add alterations to `HitObject`s while they are in their most playable state.
    func postProcess() {
        let hitObjects = beatmap.hitObjects
        if hitObjects.objects.isEmpty {
            return
        }

        // Recount nested hit object counts as they are only generated after HitObject.applyDefaults.
        hitObjects.sliderRepeatCount = 0
        hitObjects.sliderTickCount = 0

        for obj in hitObjects.objects {
            if let slider = obj as? Slider {
                hitObjects.sliderRepeatCount += slider.repeatCount
                hitObjects.sliderTickCount += slider.nestedHitObjects.count - 2 - slider.repeatCount
            }

            // Reset stacking
            obj.difficultyStackHeight = 0
            obj.gameplayStackHeight = 0
        }

        if beatmap.formatVersion >= 6 {
            applyStacking()
        } else {
            applyStackingOld()
        }
    }

    private func applyStacking() {
        let objects = beatmap.hitObjects.objects
        let startIndex = 0
        let endIndex = objects.count - 1
        var extendedEndIndex = endIndex

        if endIndex < objects.count - 1 {
            // Extend the end index to include objects they are stacked on
            for i in stride(from: endIndex, through: startIndex, by: -1) {
                var stackBaseIndex = i

                for n in (stackBaseIndex + 1)..<objects.count {
                    let stackBaseObject = objects[stackBaseIndex]
                    if stackBaseObject is Spinner {
                        break
                    }

                    let objectN = objects[n]
                    if objectN is Spinner {
                        continue
                    }

                    let endTime = stackBaseObject.endTime
                    let stackThreshold = BeatmapProcessor.calculateStackThreshold(beatmap: beatmap, hitObject: objectN)

                    if objectN.startTime - endTime > stackThreshold {
                        // We are no longer within stacking range of the next object.
                        break
                    }

                    if stackBaseObject.position.getDistanceSquared(objectN.position) < BeatmapProcessor.stackDistanceSquared ||
                        (stackBaseObject is Slider && (stackBaseObject as! Slider).endPosition.getDistanceSquared(objectN.position) < BeatmapProcessor.stackDistanceSquared)
                    {
                        stackBaseIndex = n

                        // HitObjects after the specified update range haven't been reset yet
                        objectN.difficultyStackHeight = 0
                        objectN.gameplayStackHeight = 0
                    }
                }

                if stackBaseIndex > extendedEndIndex {
                    extendedEndIndex = stackBaseIndex

                    if extendedEndIndex == objects.count - 1 {
                        break
                    }
                }
            }
        }

        // Reverse pass for stack calculation.
        var extendedStartIndex = startIndex

        for i in stride(from: extendedEndIndex, through: startIndex + 1, by: -1) {
            var n = i

            var objectI = objects[i]
            if objectI.difficultyStackHeight != 0 || objectI is Spinner {
                continue
            }

            let stackThreshold = BeatmapProcessor.calculateStackThreshold(beatmap: beatmap, hitObject: objectI)

            if objectI is HitCircle {
                n -= 1
                while n >= 0 {
                    let objectN = objects[n]
                    if objectN is Spinner {
                        n -= 1
                        continue
                    }

                    if Double(Int(objectI.startTime) - Int(objectN.endTime)) > stackThreshold {
                        // We are no longer within stacking range of the previous object.
                        break
                    }

                    // Hit objects before the specified update range haven't been reset yet
                    if n < extendedStartIndex {
                        objectN.difficultyStackHeight = 0
                        objectN.gameplayStackHeight = 0
                        extendedStartIndex = n
                    }

                    if let sliderN = objectN as? Slider, sliderN.endPosition.getDistanceSquared(objectI.position) < BeatmapProcessor.stackDistanceSquared {
                        let offset = objectI.difficultyStackHeight - objectN.difficultyStackHeight + 1

                        for j in (n + 1)...i {
                            let objectJ = objects[j]

                            if sliderN.endPosition.getDistanceSquared(objectJ.position) < BeatmapProcessor.stackDistanceSquared {
                                objectJ.difficultyStackHeight -= offset
                                objectJ.gameplayStackHeight -= offset
                            }
                        }

                        // We have hit a slider. We should restart calculation using this as the new base.
                        break
                    }

                    if objectN.position.getDistanceSquared(objectI.position) < BeatmapProcessor.stackDistanceSquared {
                        objectN.difficultyStackHeight = objectI.difficultyStackHeight + 1
                        objectN.gameplayStackHeight = objectI.gameplayStackHeight + 1
                        objectI = objectN
                    }

                    n -= 1
                }
            } else if objectI is Slider {
                n -= 1
                while n >= startIndex {
                    let objectN = objects[n]
                    if objectN is Spinner {
                        n -= 1
                        continue
                    }

                    if objectI.startTime - objectN.startTime > stackThreshold {
                        // We are no longer within stacking range of the previous object.
                        break
                    }

                    if objectN.endPosition.getDistanceSquared(objectI.position) < BeatmapProcessor.stackDistanceSquared {
                        objectN.difficultyStackHeight = objectI.difficultyStackHeight + 1
                        objectN.gameplayStackHeight = objectI.gameplayStackHeight + 1
                        objectI = objectN
                    }

                    n -= 1
                }
            }
        }
    }

    private func applyStackingOld() {
        let objects = beatmap.hitObjects.objects

        for i in 0..<objects.count {
            let currentObject = objects[i]
            if currentObject.difficultyStackHeight != 0 && !(currentObject is Slider) {
                continue
            }

            var sliderStack = 0
            var startTime = currentObject.endTime
            let stackThreshold = BeatmapProcessor.calculateStackThreshold(beatmap: beatmap, hitObject: currentObject)

            for j in (i + 1)..<objects.count {
                let objectJ = objects[j]
                if objectJ.startTime - stackThreshold > startTime {
                    break
                }

                if objectJ.position.getDistanceSquared(currentObject.position) < BeatmapProcessor.stackDistanceSquared {
                    currentObject.difficultyStackHeight += 1
                    currentObject.gameplayStackHeight += 1
                    startTime = objectJ.startTime
                } else if objectJ.position.getDistanceSquared(currentObject.endPosition) < BeatmapProcessor.stackDistanceSquared {
                    sliderStack += 1
                    objectJ.difficultyStackHeight -= sliderStack
                    objectJ.gameplayStackHeight -= sliderStack
                    startTime = objectJ.startTime
                }
            }
        }
    }

    private static func calculateStackThreshold(beatmap: IBeatmap, hitObject: HitObject) -> Double {
        return Double(Int(hitObject.timePreempt)) * Double(beatmap.general.stackLeniency)
    }
}
