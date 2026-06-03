// MARK: - ControlPointManager

/// A manager for a type of control point.
class ControlPointManager<T: ControlPoint>: Sequence {
    /// The default control point for this type.
    let defaultControlPoint: T

    /// The control points in this manager.
    var controlPoints = [T]()

    /// Creates a new `ControlPointManager`.
    ///
    /// - Parameter defaultControlPoint: The default control point for this type.
    init(defaultControlPoint: T) {
        self.defaultControlPoint = defaultControlPoint
    }

    /// Finds the control point that is active at a given time.
    ///
    /// - Parameter time: The time, in milliseconds.
    /// - Returns: The active control point at the given time.
    func controlPointAt(_ time: Double) -> T {
        fatalError("Subclasses must override controlPointAt(_:)")
    }

    /// Adds a new control point.
    ///
    /// Note that the provided control point may not be added if the correct state is already present at the control point's time.
    ///
    /// Additionally, any control point that exists in the same time will be removed.
    ///
    /// - Parameter controlPoint: The control point to add.
    /// - Returns: Whether the control point was added.
    @discardableResult
    func add(_ controlPoint: T) -> Bool {
        var existing = controlPointAt(controlPoint.time)

        if controlPoint.isRedundant(existing: existing) {
            return false
        }

        // Remove the existing control point if the new control point overrides it at the same time.
        while controlPoint.time == existing.time {
            if !remove(existing) {
                break
            }

            existing = controlPointAt(controlPoint.time)
        }

        controlPoints.insert(controlPoint, at: findInsertionIndex(controlPoint.time))

        return true
    }

    /// Removes a control point.
    ///
    /// This method will remove the earliest control point in the array that is equal to the given control point.
    ///
    /// - Parameter controlPoint: The control point to remove.
    /// - Returns: Whether the control point was removed.
    @discardableResult
    func remove(_ controlPoint: T) -> Bool {
        if let index = controlPoints.firstIndex(where: { $0 === controlPoint }) {
            controlPoints.remove(at: index)
            return true
        }
        return false
    }

    /// Removes a control point at an index.
    ///
    /// - Parameter index: The index of the control point to remove.
    /// - Returns: The control point that was removed, `nil` if no control points were removed.
    @discardableResult
    func remove(at index: Int) -> T? {
        guard index >= 0 && index <= controlPoints.count - 1 else {
            return nil
        }

        return controlPoints.remove(at: index)
    }

    /// Clears all control points in this manager.
    func clear() {
        controlPoints.removeAll()
    }

    /// Gets all control points between two times.
    ///
    /// - Parameters:
    ///   - start: The start time, in milliseconds.
    ///   - end: The end time, in milliseconds.
    /// - Returns: An array of control points between the two times. If `start` is greater than `end`, the control point at
    ///   `start` will be returned.
    func between(start: Double, end: Double) -> [T] {
        if controlPoints.isEmpty {
            return [defaultControlPoint]
        }

        if start > end {
            return [controlPointAt(start)]
        }

        // Subtract 1 from start index as the binary search from findInsertionIndex would return the next control point
        let startIndex = max(findInsertionIndex(start) - 1, 0)
        // End index does not matter as the range upper bound is exclusive
        let endIndex = min(max(findInsertionIndex(end), startIndex + 1), controlPoints.count)

        return Array(controlPoints[startIndex..<endIndex])
    }

    /// Binary searches one of the control point lists to find the active control point at the given time.
    ///
    /// Includes logic for returning the default control point when no matching point is found.
    ///
    /// - Parameters:
    ///   - time: The time to find the control point at, in milliseconds.
    ///   - fallback: The fallback control point to return if none found. Defaults to `defaultControlPoint`.
    /// - Returns: The active control point at the given time, or the fallback control point if none found.
    func binarySearchWithFallback(_ time: Double, fallback: T? = nil) -> T {
        return binarySearch(time) ?? (fallback ?? defaultControlPoint)
    }

    /// Binary searches the control point list to find the active control point at the given time.
    ///
    /// - Parameter time: The time to find the control point at, in milliseconds.
    /// - Returns: The active control point at the given time, `nil` if none found.
    func binarySearch(_ time: Double) -> T? {
        if controlPoints.isEmpty || time < controlPoints[0].time {
            return nil
        }

        let lastControlPoint = controlPoints[controlPoints.count - 1]
        if time >= lastControlPoint.time {
            return lastControlPoint
        }

        var l = 0
        var r = controlPoints.count - 2

        while l <= r {
            let pivot = l + ((r - l) >> 1)
            let controlPoint = controlPoints[pivot]

            if controlPoint.time < time {
                l = pivot + 1
            } else if controlPoint.time > time {
                r = pivot - 1
            } else {
                return controlPoint
            }
        }

        // l will be the first control point with time > controlPoint.time, but we want the one before it
        return controlPoints[l - 1]
    }

    /// Finds the insertion index of a control point in a given time.
    ///
    /// - Parameter time: The start time of the control point, in milliseconds.
    private func findInsertionIndex(_ time: Double) -> Int {
        if controlPoints.isEmpty || time < controlPoints[0].time {
            return 0
        }

        if time >= controlPoints[controlPoints.count - 1].time {
            return controlPoints.count
        }

        var l = 0
        var r = controlPoints.count - 2

        while l <= r {
            let pivot = l + ((r - l) >> 1)
            let controlPoint = controlPoints[pivot]

            if controlPoint.time < time {
                l = pivot + 1
            } else if controlPoint.time > time {
                r = pivot - 1
            } else {
                // Normally, this should only return the pivot. However, we are searching for the insertion index here.
                // If the time is equal to the control point's time, we want to insert the new control point after it.
                return pivot + 1
            }
        }

        return l
    }

    // MARK: - Sequence conformance

    func makeIterator() -> IndexingIterator<[T]> {
        return controlPoints.makeIterator()
    }
}

// MARK: - TimingControlPointManager

/// A manager for `TimingControlPoint`s.
class TimingControlPointManager: ControlPointManager<TimingControlPoint> {
    init() {
        super.init(defaultControlPoint: TimingControlPoint(time: 0.0, msPerBeat: 1000.0, timeSignature: 4))
    }

    override func controlPointAt(_ time: Double) -> TimingControlPoint {
        return binarySearchWithFallback(time, fallback: controlPoints.first ?? defaultControlPoint)
    }
}

// MARK: - DifficultyControlPointManager

/// A manager for `DifficultyControlPoint`s.
class DifficultyControlPointManager: ControlPointManager<DifficultyControlPoint> {
    init() {
        super.init(defaultControlPoint: DifficultyControlPoint(time: 0.0, speedMultiplier: 1.0, generateTicks: true))
    }

    override func controlPointAt(_ time: Double) -> DifficultyControlPoint {
        return binarySearchWithFallback(time)
    }
}

// MARK: - EffectControlPointManager

/// A manager for `EffectControlPoint`s.
class EffectControlPointManager: ControlPointManager<EffectControlPoint> {
    init() {
        super.init(defaultControlPoint: EffectControlPoint(time: 0.0, isKiai: false))
    }

    override func controlPointAt(_ time: Double) -> EffectControlPoint {
        return binarySearchWithFallback(time)
    }
}

// MARK: - SampleControlPointManager

/// A manager for `SampleControlPoint`s.
class SampleControlPointManager: ControlPointManager<SampleControlPoint> {
    init() {
        super.init(defaultControlPoint: SampleControlPoint(time: 0.0, sampleBank: .normal, sampleVolume: 100, customSampleBank: 0))
    }

    override func controlPointAt(_ time: Double) -> SampleControlPoint {
        return binarySearchWithFallback(time, fallback: controlPoints.first ?? defaultControlPoint)
    }
}
