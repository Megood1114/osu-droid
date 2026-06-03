import Foundation

/// Describes a value that can be cached and invalidated.
class Cached<T> {
    private var _value: T
    
    /// Whether the cache is valid.
    private(set) var isValid: Bool = true

    /// The cached value.
    ///
    /// - Warning: Accessing this property when the cache is invalid will trigger a fatal error.
    var value: T {
        get {
            guard isValid else {
                fatalError("May not query value of an invalid cache.")
            }
            return _value
        }
        set {
            _value = newValue
            isValid = true
        }
    }

    /// Creates a new `Cached` with the given initial value.
    ///
    /// - Parameter value: The value to cache.
    init(_ value: T) {
        self._value = value
    }

    /// Invalidates the cache.
    ///
    /// - Returns: `true` if the cache was invalidated from a valid state.
    @discardableResult
    func invalidate() -> Bool {
        if isValid {
            isValid = false
            return true
        }
        return false
    }
}
