import Foundation

/// Represents a HitObject with additional information for difficulty calculation.
open class DifficultyHitObject {
    /// A distance by which all distances should be scaled in order to assume a uniform circle size.
    public static let normalizedRadius: Float = 50.0

    /// The normalized diameter of a circle.
    public static let normalizedDiameter: Float = normalizedRadius * 2.0

    /// The minimum delta time between hit objects.
    public static let minDeltaTime: Double = 25.0

    /// The HitObject that this DifficultyHitObject wraps.
    let obj: HitObject

    /// The HitObject that occurs before `obj`.
    private let lastObj: HitObject?

    /// Other DifficultyHitObjects in the beatmap, including this DifficultyHitObject.
    public let difficultyHitObjects: [DifficultyHitObject]

    /// The index of this DifficultyHitObject in the list of all HitObjects.
    /// This is one less than the actual index of the HitObject in the beatmap.
    public let index: Int

    public var lazyJumpDistance: Double = 0.0
    public var minimumJumpDistance: Double = 0.0
    public var minimumJumpTime: Double = DifficultyHitObject.minDeltaTime
    public var travelDistance: Double = 0.0
    public var travelTime: Double = DifficultyHitObject.minDeltaTime
    var lazyEndPosition: Vector2? = nil
    public var lazyTravelDistance: Double = 0.0
    public var lazyTravelTime: Double = 0.0
    public var angle: Double? = nil

    public let deltaTime: Double
    public let strainTime: Double
    public let startTime: Double
    public let endTime: Double
    public let fullGreatWindow: Double

    open var smallCircleBonus: Double {
        fatalError("Must be overridden in subclass")
    }

    open var mode: GameMode {
        fatalError("Must be overridden in subclass")
    }

    open var maximumSliderRadius: Float {
        return DifficultyHitObject.normalizedRadius * 2.4
    }

    private var assumedSliderRadius: Float {
        return DifficultyHitObject.normalizedRadius * 1.8
    }

    private var lastDifficultyObject: DifficultyHitObject? {
        return previous(0)
    }

    private var lastLastDifficultyObject: DifficultyHitObject? {
        return previous(1)
    }

    init(
        obj: HitObject,
        lastObj: HitObject?,
        clockRate: Double,
        difficultyHitObjects: [DifficultyHitObject],
        index: Int
    ) {
        self.obj = obj
        self.lastObj = lastObj
        self.difficultyHitObjects = difficultyHitObjects
        self.index = index

        let dt = lastObj != nil ? (obj.startTime - lastObj!.startTime) / clockRate : 0.0
        self.deltaTime = dt
        self.strainTime = lastObj != nil ? max(dt, DifficultyHitObject.minDeltaTime) : 0.0
        self.startTime = obj.startTime / clockRate
        self.endTime = obj.endTime / clockRate

        let hitWindowGreat = (obj as? Slider)?.head.hitWindow?.greatWindow ?? obj.hitWindow?.greatWindow ?? 1200.0
        self.fullGreatWindow = (hitWindowGreat * 2.0) / clockRate
    }

    /// Computes the properties of this DifficultyHitObject.
    open func computeProperties(clockRate: Double) {
        computeSliderCursorPosition()
        setDistances(clockRate: clockRate)
    }

    /// Gets the DifficultyHitObject at a specific index with respect to the current DifficultyHitObject's index.
    open func previous(_ backwardsIndex: Int) -> DifficultyHitObject? {
        let prevIndex = index - (backwardsIndex + 1)
        if prevIndex >= 0 {
            return difficultyHitObjects[prevIndex]
        }
        return nil
    }

    /// Gets the DifficultyHitObject at a specific index with respect to the current DifficultyHitObject's index.
    open func next(_ forwardsIndex: Int) -> DifficultyHitObject? {
        let nextIndex = index + forwardsIndex + 1
        if nextIndex < difficultyHitObjects.count {
            return difficultyHitObjects[nextIndex]
        }
        return nil
    }

    /// Calculates the opacity of the hit object at a given time.
    open func opacityAt(time: Double, mods: [Mod]) -> Double {
        if time > obj.startTime {
            return 0.0
        }

        let fadeInStartTime = obj.startTime - obj.timePreempt
        let fadeInDuration = obj.timeFadeIn
        let nonHiddenOpacity = max(0.0, min(1.0, (time - fadeInStartTime) / fadeInDuration))

        if mods.contains(where: { $0 is ModHidden }) {
            let fadeOutStartTime = fadeInStartTime + fadeInDuration
            let fadeOutDuration = obj.timePreempt * ModHidden.fadeOutDurationMultiplier

            return min(nonHiddenOpacity, 1.0 - max(0.0, min(1.0, (time - fadeOutStartTime) / fadeOutDuration)))
        }

        return nonHiddenOpacity
    }

    /// Computes the possibility of doubletapping this DifficultyHitObject together with a next DifficultyHitObject
    public func getDoubletapness(nextObj: DifficultyHitObject?) -> Double {
        guard let nextObj = nextObj else { return 0.0 }

        let currentDeltaTime = max(1.0, deltaTime)
        let nextDeltaTime = max(1.0, nextObj.deltaTime)
        let deltaDifference = abs(nextDeltaTime - currentDeltaTime)

        let speedRatio = currentDeltaTime / max(currentDeltaTime, deltaDifference)
        let windowRatio = pow(min(1.0, currentDeltaTime / fullGreatWindow), 2.0)

        return 1.0 - pow(speedRatio, 1.0 - windowRatio)
    }

    private func setDistances(clockRate: Double) {
        if let slider = obj as? Slider {
            var multiplier = 1.0
            if mode == .droid {
                multiplier = pow(1.0 + Double(slider.repeatCount) / 4.0, 1.0 / 4.0)
            } else if mode == .standard {
                multiplier = pow(1.0 + Double(slider.repeatCount) / 2.5, 1.0 / 2.5)
            }
            travelDistance = lazyTravelDistance * multiplier
            travelTime = max(lazyTravelTime / clockRate, DifficultyHitObject.minDeltaTime)
        }

        if lastObj == nil || obj is Spinner || lastObj is Spinner {
            return
        }

        guard let lastObj = lastObj else { return }

        let scalingFactor = DifficultyHitObject.normalizedRadius / Float(obj.difficultyRadius)

        let lastCursorPosition: Vector2
        if let lastDifficultyObject = lastDifficultyObject {
            lastCursorPosition = getEndCursorPosition(obj: lastDifficultyObject)
        } else {
            lastCursorPosition = lastObj.difficultyStackedPosition
        }

        lazyJumpDistance = Double((obj.difficultyStackedPosition * scalingFactor - lastCursorPosition * scalingFactor).length)
        minimumJumpTime = strainTime
        minimumJumpDistance = lazyJumpDistance

        if lastObj is Slider, let lastDifficultyObject = lastDifficultyObject {
            let lastTravelTime = max(lastDifficultyObject.lazyTravelTime / clockRate, DifficultyHitObject.minDeltaTime)
            minimumJumpTime = max(strainTime - lastTravelTime, DifficultyHitObject.minDeltaTime)

            let tailJumpDistance = Double(((lastObj as! Slider).tail.difficultyStackedPosition - obj.difficultyStackedPosition).length * scalingFactor)

            minimumJumpDistance = max(
                0.0,
                min(
                    lazyJumpDistance - Double(maximumSliderRadius - assumedSliderRadius),
                    tailJumpDistance - Double(maximumSliderRadius)
                )
            )
        }

        if let lastLastDifficultyObject = lastLastDifficultyObject, !(lastLastDifficultyObject.obj is Spinner) {
            let lastLastCursorPosition = getEndCursorPosition(obj: lastLastDifficultyObject)
            let v1 = lastLastCursorPosition - lastObj.difficultyStackedPosition
            let v2 = obj.difficultyStackedPosition - lastCursorPosition

            let dot = v1.dot(v2)
            let det = v1.x * v2.y - v1.y * v2.x

            angle = abs(atan2(Double(det), Double(dot)))
        }
    }

    private func computeSliderCursorPosition() {
        guard let slider = obj as? Slider, lazyEndPosition == nil else { return }

        var trackingEndTime = slider.endTime
        var nestedObjects = slider.nestedHitObjects

        if mode == .standard {
            trackingEndTime = max(slider.endTime - Slider.legacyLastTickOffset, slider.startTime + slider.duration / 2.0)

            var lastRealTick: SliderTick? = nil

            for i in stride(from: nestedObjects.count - 2, through: 1, by: -1) {
                let current = nestedObjects[i]
                if let tick = current as? SliderTick {
                    lastRealTick = tick
                    break
                }
                if current is SliderRepeat {
                    break
                }
            }

            if let lastRealTick = lastRealTick, lastRealTick.startTime > trackingEndTime {
                trackingEndTime = lastRealTick.startTime

                var reordered = nestedObjects
                if let index = reordered.firstIndex(where: { $0 === lastRealTick }) {
                    reordered.remove(at: index)
                    reordered.append(lastRealTick)
                }
                nestedObjects = reordered
            }
        }

        if mode == .droid {
            lazyEndPosition = slider.difficultyStackedPosition
            if abs(slider.startTime - slider.endTime) < 0.001 {
                return
            }
        }

        lazyTravelTime = trackingEndTime - slider.startTime

        var endTimeMin = lazyTravelTime / slider.spanDuration
        if endTimeMin.truncatingRemainder(dividingBy: 2.0) >= 1.0 {
            endTimeMin = 1.0 - endTimeMin.truncatingRemainder(dividingBy: 1.0)
        } else {
            endTimeMin = endTimeMin.truncatingRemainder(dividingBy: 1.0)
        }

        lazyEndPosition = slider.difficultyStackedPosition + slider.path.positionAt(endTimeMin)

        var currentCursorPosition = slider.difficultyStackedPosition
        let scalingFactor = Double(DifficultyHitObject.normalizedRadius / Float(slider.difficultyRadius))

        if nestedObjects.count > 1 {
            for i in 1..<nestedObjects.count {
                let currentMovementObject = nestedObjects[i]
                var currentMovement = currentMovementObject.difficultyStackedPosition - currentCursorPosition
                var currentMovementLength = scalingFactor * Double(currentMovement.length)

                var requiredMovement = Double(assumedSliderRadius)

                if i == nestedObjects.count - 1 {
                    if let lazyPos = lazyEndPosition {
                        let lazyMovement = lazyPos - currentCursorPosition
                        if lazyMovement.length < currentMovement.length {
                            currentMovement = lazyMovement
                        }
                    }
                    currentMovementLength = scalingFactor * Double(currentMovement.length)
                } else if currentMovementObject is SliderRepeat {
                    requiredMovement = Double(DifficultyHitObject.normalizedRadius)
                }

                if currentMovementLength > requiredMovement {
                    let ratio = Float((currentMovementLength - requiredMovement) / currentMovementLength)
                    currentCursorPosition = currentCursorPosition + currentMovement * ratio

                    currentMovementLength *= (currentMovementLength - requiredMovement) / currentMovementLength
                    lazyTravelDistance += currentMovementLength
                }

                if i == nestedObjects.count - 1 {
                    lazyEndPosition = currentCursorPosition
                }
            }
        }
    }

    private func getEndCursorPosition(obj: DifficultyHitObject) -> Vector2 {
        return obj.lazyEndPosition ?? obj.obj.difficultyStackedPosition
    }
}
