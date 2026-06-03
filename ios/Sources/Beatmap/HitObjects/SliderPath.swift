import Foundation

/// Represents the path of a `Slider`.
class SliderPath {
    /// The path type of the `Slider`.
    let pathType: SliderPathType

    /// The control points (anchor points) of this `SliderPath`.
    let controlPoints: [Vector2]

    /// The distance that is expected when calculating `SliderPath`.
    let expectedDistance: Double

    /// The calculated path of this `SliderPath`.
    private(set) var calculatedPath = [Vector2]()

    /// The cumulative length of this `SliderPath`.
    private(set) var cumulativeLength = [Double]()

    /// Creates a new `SliderPath`.
    ///
    /// - Parameters:
    ///   - pathType: The path type of the `Slider`.
    ///   - controlPoints: The control points (anchor points) of this `SliderPath`.
    ///   - expectedDistance: The distance that is expected when calculating `SliderPath`.
    init(pathType: SliderPathType, controlPoints: [Vector2], expectedDistance: Double) {
        self.pathType = pathType
        self.controlPoints = controlPoints
        self.expectedDistance = expectedDistance

        calculatePath()
        calculateCumulativeLength()
    }

    /// Computes the position on the `Slider` at a given progress that ranges from 0
    /// (beginning of the path) to 1 (end of the path).
    ///
    /// - Parameter progress: Ranges from 0 (beginning of the path) to 1 (end of the path).
    func positionAt(_ progress: Double) -> Vector2 {
        let d = progressToDistance(progress)
        return interpolateVertices(indexOfDistance(d), d)
    }

    /// Computes the slider path until a given progress that ranges from 0 (beginning of the slider) to 1 (end of the
    /// slider).
    ///
    /// - Parameters:
    ///   - p0: Start progress. Ranges from 0 (beginning of the slider) to 1 (end of the slider).
    ///   - p1: End progress. Ranges from 0 (beginning of the slider) to 1 (end of the slider).
    /// - Returns: The computed path between the two ranges.
    func getPathToProgress(_ p0: Double, _ p1: Double) -> [Vector2] {
        let d0 = progressToDistance(p0)
        let d1 = progressToDistance(p1)

        let startEstimate = indexOfDistance(d0)
        let endEstimate = indexOfDistance(d1)

        let estimatedSize =
            endEstimate >= startEstimate ? endEstimate - startEstimate + 3 : startEstimate - endEstimate + 3

        var path = [Vector2]()
        path.reserveCapacity(estimatedSize)

        var i = 0

        while i < calculatedPath.count && cumulativeLength[i] < d0 {
            i += 1
        }

        path.append(interpolateVertices(i, d0))

        while i < calculatedPath.count && cumulativeLength[i] <= d1 {
            path.append(calculatedPath[i])
            i += 1
        }

        path.append(interpolateVertices(i, d1))

        return path
    }

    // MARK: - Private Methods

    /// Calculates the path of this `SliderPath`.
    private func calculatePath() {
        calculatedPath.removeAll()

        if controlPoints.isEmpty {
            return
        }

        calculatedPath.append(controlPoints[0])
        var spanStart = 0

        for i in controlPoints.indices {
            if i == controlPoints.count - 1 || controlPoints[i] == controlPoints[i + 1] {
                let spanEnd = i + 1
                let cpSpan = Array(controlPoints[spanStart..<spanEnd])

                for t in calculateSubPath(cpSpan) {
                    if calculatedPath.isEmpty || calculatedPath[calculatedPath.count - 1] != t {
                        calculatedPath.append(t)
                    }
                }

                spanStart = spanEnd
            }
        }
    }

    /// Calculates the cumulative length of this `SliderPath`.
    private func calculateCumulativeLength() {
        cumulativeLength.removeAll()
        cumulativeLength.append(0.0)

        var calculatedLength: Double = 0.0

        for i in 0..<(calculatedPath.count - 1) {
            calculatedLength += Double(calculatedPath[i + 1].getDistance(calculatedPath[i]))
            cumulativeLength.append(calculatedLength)
        }

        if calculatedLength != expectedDistance {
            // In osu-stable, if the last two control points of a slider are equal, extension is not performed.
            if controlPoints.count >= 2
                && controlPoints[controlPoints.count - 1] == controlPoints[controlPoints.count - 2]
                && expectedDistance > calculatedLength
            {
                return
            }

            // The last length is always incorrect.
            cumulativeLength.removeLast()
            var pathEndIndex = calculatedPath.count - 1

            if calculatedLength > expectedDistance {
                // The path will be shortened further, in which case we should trim any more
                // unnecessary lengths and their associated path segments
                while !cumulativeLength.isEmpty && cumulativeLength[cumulativeLength.count - 1] >= expectedDistance {
                    cumulativeLength.removeLast()
                    calculatedPath.remove(at: pathEndIndex)
                    pathEndIndex -= 1
                }
            }

            if pathEndIndex <= 0 {
                // The expected distance is negative or zero
                cumulativeLength.append(0.0)
                return
            }

            // The direction of the segment to shorten or lengthen.
            // Use scalar math to avoid temporary Vector2 allocations in this hot path.
            let previousPoint = calculatedPath[pathEndIndex - 1]
            let endPoint = calculatedPath[pathEndIndex]

            let lengthSquared = endPoint.getDistanceSquared(previousPoint)
            let inverseLength: Float = lengthSquared == 0 ? 0 : 1 / sqrt(lengthSquared)
            let ext = Float(expectedDistance - cumulativeLength[cumulativeLength.count - 1])

            calculatedPath[pathEndIndex] = Vector2(
                x: previousPoint.x + (endPoint.x - previousPoint.x) * inverseLength * ext,
                y: previousPoint.y + (endPoint.y - previousPoint.y) * inverseLength * ext
            )

            cumulativeLength.append(expectedDistance)
        }
    }

    private func calculateSubPath(_ subControlPoints: [Vector2]) -> [Vector2] {
        switch pathType {
        case .linear:
            return PathApproximation.approximateLinear(subControlPoints)
        case .perfectCurve:
            if subControlPoints.count == 3 {
                return PathApproximation.approximateCircularArc(subControlPoints)
            } else {
                return PathApproximation.approximateBezier(subControlPoints)
            }
        case .catmull:
            return PathApproximation.approximateCatmull(subControlPoints)
        case .bezier:
            return PathApproximation.approximateBezier(subControlPoints)
        }
    }

    /// Returns the progress of reaching expected distance.
    private func progressToDistance(_ progress: Double) -> Double {
        progress.clamped(to: 0.0...1.0) * expectedDistance
    }

    /// Interpolates vertices of the `SliderPath` at a certain point.
    private func interpolateVertices(_ i: Int, _ d: Double) -> Vector2 {
        if calculatedPath.isEmpty {
            return Vector2(value: 0)
        }

        if i <= 0 {
            return calculatedPath[0]
        }

        if i >= calculatedPath.count {
            return calculatedPath[calculatedPath.count - 1]
        }

        let p0 = calculatedPath[i - 1]
        let p1 = calculatedPath[i]
        let d0 = cumulativeLength[i - 1]
        let d1 = cumulativeLength[i]

        // Avoid division by and almost-zero number in case two points are extremely close to each other.
        if Precision.almostEquals(d0, d1) {
            return p0
        }

        let w = (d - d0) / (d1 - d0)
        let t = Float(w)

        return Vector2(
            x: p0.x + (p1.x - p0.x) * t,
            y: p0.y + (p1.y - p0.y) * t
        )
    }

    /// Binary searches the cumulative length array and returns the
    /// index at which the index of the array is more than `d`.
    ///
    /// - Parameter d: The distance to search.
    /// - Returns: The index.
    private func indexOfDistance(_ d: Double) -> Int {
        if cumulativeLength.isEmpty || d < cumulativeLength[0] {
            return 0
        }

        if d >= cumulativeLength[cumulativeLength.count - 1] {
            return cumulativeLength.count
        }

        var l = 0
        var r = cumulativeLength.count - 2

        while l <= r {
            let pivot = l + (r - l) >> 1
            let length = cumulativeLength[pivot]

            if length < d {
                l = pivot + 1
            } else if length > d {
                r = pivot - 1
            } else {
                return pivot
            }
        }

        return l
    }
}

// MARK: - Comparable clamped extension

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
