import Foundation
import CoreGraphics

/// Represents a two-dimensional vector.
struct Vector2: Equatable, Hashable, CustomStringConvertible {
    /// The X position of the vector.
    var x: Float

    /// The Y position of the vector.
    var y: Float

    /// Creates a vector with the given X and Y components.
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    /// Creates a vector with both components set to the same integer value.
    init(value: Int) {
        self.x = Float(value)
        self.y = Float(value)
    }

    /// Creates a vector from integer X and Y values.
    init(x: Int, y: Int) {
        self.x = Float(x)
        self.y = Float(y)
    }

    /// Creates a vector with both components set to the same float value.
    init(value: Float) {
        self.x = value
        self.y = value
    }

    /// Creates a vector from a `CGPoint`.
    init(cgPoint: CGPoint) {
        self.x = Float(cgPoint.x)
        self.y = Float(cgPoint.y)
    }

    /// A zero vector.
    static let zero = Vector2(x: 0, y: 0)

    /// The length of this vector.
    var length: Float {
        hypot(x, y)
    }

    /// The square of this vector's length (magnitude).
    ///
    /// This property eliminates the costly square root operation required by the
    /// ``length`` property. This makes it more suitable for comparisons.
    var lengthSquared: Float {
        x * x + y * y
    }

    /// Converts this vector to a `CGPoint`.
    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    /// Performs a dot multiplication with another vector.
    ///
    /// - Parameter vec: The other vector.
    /// - Returns: The dot product of both vectors.
    func dot(_ vec: Vector2) -> Float {
        x * vec.x + y * vec.y
    }

    /// Gets the distance between this vector and another vector.
    ///
    /// - Parameter vec: The other vector.
    /// - Returns: The distance between this vector and the other vector.
    func getDistance(_ vec: Vector2) -> Float {
        hypot(vec.x - x, vec.y - y)
    }

    /// Gets the square of distance between this vector and another vector.
    ///
    /// This avoids square root calculation and is suitable for distance comparisons.
    ///
    /// - Parameter vec: The other vector.
    /// - Returns: The square of distance between this vector and the other vector.
    func getDistanceSquared(_ vec: Vector2) -> Float {
        let dx = vec.x - x
        let dy = vec.y - y

        return dx * dx + dy * dy
    }

    /// Gets the square of distance between this vector and a point.
    ///
    /// - Parameters:
    ///   - x: The X coordinate of the point.
    ///   - y: The Y coordinate of the point.
    /// - Returns: The square of distance between this vector and the point.
    func getDistanceSquared(x: Float, y: Float) -> Float {
        let dx = x - self.x
        let dy = y - self.y

        return dx * dx + dy * dy
    }

    /// Normalizes the vector in place.
    mutating func normalize() {
        let lenSq = lengthSquared

        if lenSq == 0 {
            return
        }

        let inverseLength = 1 / sqrt(lenSq)

        x *= inverseLength
        y *= inverseLength
    }

    /// Returns a normalized copy of this vector.
    ///
    /// - Returns: A new vector with the same direction and a length of 1.
    func normalized() -> Vector2 {
        var copy = self
        copy.normalize()
        return copy
    }

    /// Gets the square of distance between two points.
    ///
    /// - Parameters:
    ///   - x1: The X coordinate of the first point.
    ///   - y1: The Y coordinate of the first point.
    ///   - x2: The X coordinate of the second point.
    ///   - y2: The Y coordinate of the second point.
    /// - Returns: The square of distance between the two points.
    static func distanceSquared(x1: Float, y1: Float, x2: Float, y2: Float) -> Float {
        let dx = x2 - x1
        let dy = y2 - y1

        return dx * dx + dy * dy
    }

    var description: String {
        "Vector2(x: \(x), y: \(y))"
    }

    // MARK: - Arithmetic Operators

    /// Multiplies this vector with another vector (component-wise).
    ///
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    /// - Returns: The multiplied vector.
    static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    /// Scales this vector by an integer factor.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - scaleFactor: The factor to scale the vector by.
    /// - Returns: The scaled vector.
    static func * (lhs: Vector2, scaleFactor: Int) -> Vector2 {
        lhs * Float(scaleFactor)
    }

    /// Scales this vector by a float factor.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - scaleFactor: The factor to scale the vector by.
    /// - Returns: The scaled vector.
    static func * (lhs: Vector2, scaleFactor: Float) -> Vector2 {
        Vector2(x: lhs.x * scaleFactor, y: lhs.y * scaleFactor)
    }

    /// Scales this vector by a double factor.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - scaleFactor: The factor to scale the vector by.
    /// - Returns: The scaled vector.
    static func * (lhs: Vector2, scaleFactor: Double) -> Vector2 {
        lhs * Float(scaleFactor)
    }

    /// Divides this vector by an integer scalar.
    ///
    /// Attempting to divide by 0 will trigger a fatal error.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - divideFactor: The factor to divide the vector by.
    /// - Returns: The divided vector.
    static func / (lhs: Vector2, divideFactor: Int) -> Vector2 {
        lhs / Float(divideFactor)
    }

    /// Divides this vector by a float scalar.
    ///
    /// Attempting to divide by 0 will trigger a fatal error.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - divideFactor: The factor to divide the vector by.
    /// - Returns: The divided vector.
    static func / (lhs: Vector2, divideFactor: Float) -> Vector2 {
        guard divideFactor != 0 else {
            fatalError("Division by 0")
        }
        return Vector2(x: lhs.x / divideFactor, y: lhs.y / divideFactor)
    }

    /// Divides this vector by a double scalar.
    ///
    /// Attempting to divide by 0 will trigger a fatal error.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - divideFactor: The factor to divide the vector by.
    /// - Returns: The divided vector.
    static func / (lhs: Vector2, divideFactor: Double) -> Vector2 {
        lhs / Float(divideFactor)
    }

    /// Adds a scalar to each component of this vector.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - n: The scalar to add.
    /// - Returns: The added vector.
    static func + (lhs: Vector2, n: Float) -> Vector2 {
        Vector2(x: lhs.x + n, y: lhs.y + n)
    }

    /// Adds this vector with another vector.
    ///
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    /// - Returns: The added vector.
    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Adds a scalar to each component of this vector in place.
    ///
    /// - Parameters:
    ///   - lhs: The vector to mutate.
    ///   - n: The scalar to add.
    static func += (lhs: inout Vector2, n: Float) {
        lhs.x += n
        lhs.y += n
    }

    /// Adds another vector to this vector in place.
    ///
    /// - Parameters:
    ///   - lhs: The vector to mutate.
    ///   - rhs: The other vector.
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    /// Subtracts a scalar from each component of this vector.
    ///
    /// - Parameters:
    ///   - lhs: The vector.
    ///   - n: The scalar to subtract.
    /// - Returns: The subtracted vector.
    static func - (lhs: Vector2, n: Float) -> Vector2 {
        Vector2(x: lhs.x - n, y: lhs.y - n)
    }

    /// Subtracts another vector from this vector.
    ///
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    /// - Returns: The subtracted vector.
    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Subtracts a scalar from each component of this vector in place.
    ///
    /// - Parameters:
    ///   - lhs: The vector to mutate.
    ///   - n: The scalar to subtract.
    static func -= (lhs: inout Vector2, n: Float) {
        lhs.x -= n
        lhs.y -= n
    }

    /// Subtracts another vector from this vector in place.
    ///
    /// - Parameters:
    ///   - lhs: The vector to mutate.
    ///   - rhs: The other vector.
    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    /// Negates this vector.
    ///
    /// - Parameter vec: The vector to negate.
    /// - Returns: The negated vector.
    static prefix func - (vec: Vector2) -> Vector2 {
        Vector2(x: -vec.x, y: -vec.y)
    }
}
