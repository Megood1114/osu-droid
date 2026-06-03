import Foundation

/// Contains information about hit objects of a beatmap.
open class BeatmapHitObjects: Sequence {
    /// All objects in this beatmap.
    public var objects: [HitObject] = []

    /// The amount of circles in this beatmap.
    public private(set) var circleCount: Int = 0

    /// The amount of sliders in this beatmap.
    public private(set) var sliderCount: Int = 0

    /// The amount of spinners in this beatmap.
    public private(set) var spinnerCount: Int = 0

    /// The amount of slider repeats in this beatmap.
    internal var sliderRepeatCount: Int = 0

    /// The amount of slider ticks in this beatmap.
    internal var sliderTickCount: Int = 0
    
    public init() {}

    /// Adds hit objects to this beatmap.
    ///
    /// - Parameter objects: The hit objects to add.
    open func add(_ newObjects: [HitObject]) {
        newObjects.forEach { add($0) }
    }

    /// Adds a hit object to this beatmap.
    ///
    /// - Parameter obj: The hit object to add.
    open func add(_ obj: HitObject) {
        // Objects may be out of order *only* if a user has manually edited an .osu file.
        // Finding index is used to guarantee that the parsing order of hit objects with equal start times is maintained (stably-sorted).
        objects.insert(obj, at: findInsertionIndex(startTime: obj.startTime))

        if obj is HitCircle {
            circleCount += 1
        } else if let slider = obj as? Slider {
            sliderCount += 1
            sliderTickCount += slider.nestedHitObjects.filter { $0 is SliderTick }.count
        } else {
            spinnerCount += 1
        }
    }

    /// Removes a hit object from this beatmap.
    ///
    /// - Parameter obj: The hit object to remove.
    /// - Returns: Whether the hit object was successfully removed.
    open func remove(_ obj: HitObject) -> Bool {
        if let index = objects.firstIndex(where: { $0 === obj }) {
            objects.remove(at: index)
            
            if obj is HitCircle {
                circleCount -= 1
            } else if let slider = obj as? Slider {
                sliderCount -= 1
                sliderTickCount -= slider.nestedHitObjects.filter { $0 is SliderTick }.count
            } else {
                spinnerCount -= 1
            }
            
            return true
        }
        return false
    }

    /// Removes a hit object from this beatmap at a given index.
    ///
    /// - Parameter index: The index of the hit object to remove.
    /// - Returns: The hit object that was removed, `nil` if no hit objects were removed.
    open func remove(at index: Int) -> HitObject? {
        if index < 0 || index >= objects.count {
            return nil
        }

        let removed = objects.remove(at: index)
        if removed is HitCircle {
            circleCount -= 1
        } else if removed is Slider {
            sliderCount -= 1
        } else {
            spinnerCount -= 1
        }
        return removed
    }

    /// Clears all hit objects from this beatmap.
    open func clear() {
        objects.removeAll()
        circleCount = 0
        sliderCount = 0
        spinnerCount = 0
    }

    /// Finds the insertion index of a hit object in a given time.
    ///
    /// - Parameter startTime: The start time of the hit object.
    private func findInsertionIndex(startTime: Double) -> Int {
        if objects.isEmpty || startTime < objects[0].startTime {
            return 0
        }

        if startTime >= objects[objects.count - 1].startTime {
            return objects.count
        }

        var l = 0
        var r = objects.count - 2

        while l <= r {
            let pivot = l + ((r - l) >> 1)
            let obj = objects[pivot]
            let objStartTime = obj.startTime

            if objStartTime < startTime {
                l = pivot + 1
            } else if objStartTime > startTime {
                r = pivot - 1
            } else {
                return pivot
            }
        }

        return l
    }

    public func makeIterator() -> IndexingIterator<[HitObject]> {
        return objects.makeIterator()
    }
}
