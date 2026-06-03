import Foundation

/// Helper methods to approximate a path by interpolating a sequence of control points.
enum PathApproximation {
    /// The amount of pieces to calculate for each control point quadruplet.
    public static let catmullDetail = 50

    private static let bezierTolerance: Float = 0.25
    private static let circularArcTolerance: Float = 0.1
    private static let bezierToleranceThreshold: Float = bezierTolerance * bezierTolerance * 4

    /// Creates a piecewise-linear approximation of a Bézier curve by adaptively repeatedly subdividing
    /// the control points until their approximation error vanishes below a given threshold.
    ///
    /// - Parameter controlPoints: The control points of the curve.
    /// - Returns: The points representing the resulting piecewise-linear approximation.
    static func approximateBezier(_ controlPoints: [Vector2]) -> [Vector2] {
        var output = [Vector2]()
        let count = controlPoints.count - 1

        if count < 0 {
            return output
        }
        // "toFlatten" contains all the curves which are not yet approximated well enough.
        // We use a stack to emulate recursion without the risk of running into a stack overflow.
        var toFlatten = [([Vector2?], Int)]()
        var freeBuffers = [[Vector2?]]()

        toFlatten.append((controlPoints.map { $0 as Vector2? }, 0))
        var subdivisionBuffer1 = [Vector2?](repeating: nil, count: count + 1)
        var subdivisionBuffer2 = [Vector2?](repeating: nil, count: count * 2 + 1)

        while !toFlatten.isEmpty {
            let item = toFlatten.removeLast()
            var parent = item.0
            let depth = item.1

            // Prevent infinite memory loop in case of floating point inaccuracies or extreme curves
            if depth > 100 || bezierIsFlatEnough(parent) {
                bezierApproximate(&parent, &output, &subdivisionBuffer1, &subdivisionBuffer2, count + 1)
                freeBuffers.append(parent)
                continue
            }

            // If we do not yet have a sufficiently "flat" (in other words, detailed) approximation we keep
            // subdividing the curve we are currently operating on.
            var rightChild = freeBuffers.isEmpty ? [Vector2?](repeating: nil, count: count + 1) : freeBuffers.removeLast()
            bezierSubdivide(&parent, &subdivisionBuffer2, &rightChild, &subdivisionBuffer1, count + 1)

            // We re-use the buffer of the parent for one of the children, so that we save one allocation per iteration.
            for i in 0...count {
                parent[i] = subdivisionBuffer2[i]
            }

            toFlatten.append((rightChild, depth + 1))
            toFlatten.append((parent, depth + 1))
        } }

        output.append(controlPoints[count])
        return output
    }

    /// Creates a piecewise-linear approximation of a Catmull-Rom spline.
    ///
    /// - Parameter controlPoints: The control points.
    /// - Returns: The points representing the resulting piecewise-linear approximation.
    static func approximateCatmull(_ controlPoints: [Vector2]) -> [Vector2] {
        let segmentCount = max(controlPoints.count - 1, 0)
        var result = [Vector2]()
        result.reserveCapacity(segmentCount * catmullDetail * 2)
        let inverseDetail: Float = 1.0 / Float(catmullDetail)

        for i in 0..<(controlPoints.count - 1) {
            let v1 = i > 0 ? controlPoints[i - 1] : controlPoints[i]
            let v2 = controlPoints[i]
            let v3 = i < controlPoints.count - 1
                ? controlPoints[i + 1]
                : Vector2(2 * v2.x - v1.x, 2 * v2.y - v1.y)
            let v4 = i < controlPoints.count - 2
                ? controlPoints[i + 2]
                : Vector2(2 * v3.x - v2.x, 2 * v3.y - v2.y)

            for c in 0..<catmullDetail {
                result.append(catmullFindPoint(v1, v2, v3, v4, Float(c) * inverseDetail))
                result.append(catmullFindPoint(v1, v2, v3, v4, Float(c + 1) * inverseDetail))
            }
        }

        return result
    }

    /// Creates a piecewise-linear approximation of a circular arc curve.
    ///
    /// - Parameter controlPoints: The control points.
    /// - Returns: The points representing the resulting piecewise-linear approximation.
    static func approximateCircularArc(_ controlPoints: [Vector2]) -> [Vector2] {
        if controlPoints.count != 3 {
            return approximateBezier(controlPoints)
        }

        let a = controlPoints[0]
        let b = controlPoints[1]
        let c = controlPoints[2]

        // If we have a degenerate triangle where a side-length is almost zero, then give up and fall
        // back to a more numerically stable method.
        if Precision.almostEquals(0, (b.y - a.y) * (c.x - a.x) - (b.x - a.x) * (c.y - a.y)) {
            return approximateBezier(controlPoints)
        }

        // See: https://en.wikipedia.org/wiki/Circumscribed_circle#Cartesian_coordinates_2
        let d = 2 * (a.x * (b.y - a.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))
        let aSq = a.lengthSquared
        let bSq = b.lengthSquared
        let cSq = c.lengthSquared

        let centerX = (aSq * (b.y - c.y) + bSq * (c.y - a.y) + cSq * (a.y - b.y)) / d
        let centerY = (aSq * (c.x - b.x) + bSq * (a.x - c.x) + cSq * (b.x - a.x)) / d

        let radius = hypot(a.x - centerX, a.y - centerY)
        let thetaStart = atan2(Double(a.y - centerY), Double(a.x - centerX))
        var thetaEnd = atan2(Double(c.y - centerY), Double(c.x - centerX))

        while thetaEnd < thetaStart {
            thetaEnd += 2 * Double.pi
        }

        var direction = 1.0
        var thetaRange = thetaEnd - thetaStart

        // Decide in which direction to draw the circle, depending on which side of
        // AC B lies.
        let orthoX = c.y - a.y
        let orthoY = -(c.x - a.x)

        if orthoX * (b.x - a.x) + orthoY * (b.y - a.y) < 0 {
            direction = -direction
            thetaRange = 2 * Double.pi - thetaRange
        }

        // We select the amount of points for the approximation by requiring the discrete curvature
        // to be smaller than the provided tolerance. The exact angle required to meet the tolerance
        // is: 2 * acos(1 - TOLERANCE / radius)
        // The special case is required for extremely short sliders where the radius is smaller than
        // the tolerance. This is a pathological rather than a realistic case.
        let amountPoints: Int
        if 2 * radius <= circularArcTolerance {
            amountPoints = 2
        } else {
            amountPoints = max(
                2,
                Int(ceil(thetaRange / (2 * acos(1 - Double(circularArcTolerance) / Double(radius)))))
            )
        }

        var output = [Vector2]()
        output.reserveCapacity(amountPoints)

        for i in 0..<amountPoints {
            let fraction = Double(i) / Double(amountPoints - 1)
            let theta = thetaStart + direction * fraction * thetaRange

            output.append(
                Vector2(
                    centerX + Float(cos(theta)) * radius,
                    centerY + Float(sin(theta)) * radius
                )
            )
        }

        return output
    }

    /// Creates a piecewise-linear approximation of a linear curve.
    /// Basically, returns the input.
    ///
    /// - Parameter controlPoints: The control points.
    /// - Returns: The control points as-is.
    static func approximateLinear(_ controlPoints: [Vector2]) -> [Vector2] {
        return controlPoints
    }

    /// Checks if a Bézier curve is flat enough to be approximated.
    ///
    /// Make sure the 2nd order derivative (approximated using finite elements) is within tolerable bounds.
    ///
    /// NOTE: The 2nd order derivative of a 2D curve represents its curvature, so intuitively this function
    /// checks (as the name suggests) whether our approximation is *locally* "flat". More curvy parts
    /// need to have a denser approximation to be more "flat".
    ///
    /// - Parameter controlPoints: The control points.
    /// - Returns: `true` if the curve is flat enough.
    private static func bezierIsFlatEnough(_ controlPoints: [Vector2?]) -> Bool {
        for i in 1..<(controlPoints.count - 1) {
            let prev = controlPoints[i - 1]!
            let current = controlPoints[i]!
            let next = controlPoints[i + 1]!
            let dx = prev.x - current.x * 2 + next.x
            let dy = prev.y - current.y * 2 + next.y
            let lengthSquared = dx * dx + dy * dy

            if lengthSquared > bezierToleranceThreshold {
                return false
            }
        }

        return true
    }

    /// Approximates a Bézier curve.
    ///
    /// This uses [De Casteljau's algorithm](https://en.wikipedia.org/wiki/De_Casteljau%27s_algorithm) to obtain an optimal
    /// piecewise-linear approximation of the Bézier curve with the same amount of points as there are control points.
    ///
    /// - Parameters:
    ///   - controlPoints: The control points describing the Bézier curve to be approximated.
    ///   - output: The points representing the resulting piecewise-linear approximation.
    ///   - subdivisionBuffer1: The first buffer containing the current subdivision state.
    ///   - subdivisionBuffer2: The second buffer containing the current subdivision state.
    ///   - count: The number of control points in the original array.
    private static func bezierApproximate(
        _ controlPoints: inout [Vector2?],
        _ output: inout [Vector2],
        _ subdivisionBuffer1: inout [Vector2?],
        _ subdivisionBuffer2: inout [Vector2?],
        _ count: Int
    ) {
        var tempBuffer = subdivisionBuffer1
        bezierSubdivide(&controlPoints, &subdivisionBuffer2, &subdivisionBuffer1, &tempBuffer, count)

        if count > 1 {
            // System.arraycopy(subdivisionBuffer1, 1, subdivisionBuffer2, count, count - 1)
            for i in 0..<(count - 1) {
                subdivisionBuffer2[count + i] = subdivisionBuffer1[1 + i]
            }
        }

        output.append(controlPoints[0]!)

        for i in 1..<(count - 1) {
            let index = 2 * i
            let prev = subdivisionBuffer2[index - 1]!
            let current = subdivisionBuffer2[index]!
            let next = subdivisionBuffer2[index + 1]!

            let p = Vector2(
                0.25 * (prev.x + current.x * 2 + next.x),
                0.25 * (prev.y + current.y * 2 + next.y)
            )

            output.append(p)
        }
    }

    /// Subdivides `n` control points representing a Bézier curve into 2 sets of `n`
    /// control points, each describing a Bézier curve equivalent to a half of the original curve.
    /// Effectively this splits the original curve into 2 curves which result in the original curve
    /// when pieced back together.
    ///
    /// - Parameters:
    ///   - controlPoints: The anchor points of the slider.
    ///   - l: Parts of the slider for approximation.
    ///   - r: Parts of the slider for approximation.
    ///   - subdivisionBuffer: Parts of the slider for approximation.
    ///   - count: The amount of anchor points in the slider.
    private static func bezierSubdivide(
        _ controlPoints: inout [Vector2?],
        _ l: inout [Vector2?],
        _ r: inout [Vector2?],
        _ subdivisionBuffer: inout [Vector2?],
        _ count: Int
    ) {
        for i in 0..<count {
            subdivisionBuffer[i] = controlPoints[i]
        }

        for i in 0..<count {
            l[i] = subdivisionBuffer[0]
            r[count - i - 1] = subdivisionBuffer[count - i - 1]

            for j in 0..<(count - i - 1) {
                let left = subdivisionBuffer[j]!
                let right = subdivisionBuffer[j + 1]!

                subdivisionBuffer[j] = Vector2(
                    (left.x + right.x) * 0.5,
                    (left.y + right.y) * 0.5
                )
            }
        }
    }

    /// Finds a point on the spline at the position of a parameter.
    ///
    /// - Parameters:
    ///   - vec1: The first vector.
    ///   - vec2: The second vector.
    ///   - vec3: The third vector.
    ///   - vec4: The fourth vector.
    ///   - t: The parameter at which to find the point on the spline, in the range `[0, 1]`.
    /// - Returns: The point on the spline at the given parameter.
    private static func catmullFindPoint(
        _ vec1: Vector2,
        _ vec2: Vector2,
        _ vec3: Vector2,
        _ vec4: Vector2,
        _ t: Float
    ) -> Vector2 {
        let t2 = t * t
        let t3 = t2 * t

                let x = 0.5 * (2 * vec2.x + (-vec1.x + vec3.x) * t + (2 * vec1.x - 5 * vec2.x + 4 * vec3.x - vec4.x) * t2 + (-vec1.x + 3 * vec2.x - 3 * vec3.x + vec4.x) * t3)
        let y = 0.5 * (2 * vec2.y + (-vec1.y + vec3.y) * t + (2 * vec1.y - 5 * vec2.y + 4 * vec3.y - vec4.y) * t2 + (-vec1.y + 3 * vec2.y - 3 * vec3.y + vec4.y) * t3)

        return Vector2(x: x, y: y)
    }
}
