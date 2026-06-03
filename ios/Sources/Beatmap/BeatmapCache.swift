import Foundation

private class LRUCacheNode<Key, Value> {
    let key: Key
    var value: Value
    var prev: LRUCacheNode?
    var next: LRUCacheNode?

    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}

private class LRUCache<Key: Hashable, Value> {
    private let capacity: Int
    private var cache: [Key: LRUCacheNode<Key, Value>] = [:]
    private var head: LRUCacheNode<Key, Value>?
    private var tail: LRUCacheNode<Key, Value>?

    init(capacity: Int) {
        self.capacity = capacity
    }

    func get(_ key: Key) -> Value? {
        guard let node = cache[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    func set(_ key: Key, value: Value) {
        if let node = cache[key] {
            node.value = value
            moveToHead(node)
        } else {
            let newNode = LRUCacheNode(key: key, value: value)
            cache[key] = newNode
            addToHead(newNode)
            if cache.count > capacity {
                if let tail = tail {
                    cache.removeValue(forKey: tail.key)
                    removeNode(tail)
                }
            }
        }
    }

    func remove(_ key: Key) {
        if let node = cache[key] {
            cache.removeValue(forKey: key)
            removeNode(node)
        }
    }

    func clear() {
        cache.removeAll()
        head = nil
        tail = nil
    }

    private func moveToHead(_ node: LRUCacheNode<Key, Value>) {
        removeNode(node)
        addToHead(node)
    }

    private func removeNode(_ node: LRUCacheNode<Key, Value>) {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }
        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }
    }

    private func addToHead(_ node: LRUCacheNode<Key, Value>) {
        node.next = head
        node.prev = nil
        if let head = head {
            head.prev = node
        }
        head = node
        if tail == nil {
            tail = node
        }
    }
}

/// A cache for caching `Beatmap`s that have been parsed. Supports `Beatmap`s that have been parsed with or without hit
/// objects, and will automatically reparse a `Beatmap` if it is requested with hit objects but is only cached without them.
///
/// This cache is thread-safe.
public final class BeatmapCache {
    public static let shared = BeatmapCache()
    private init() {}

    private let lock = NSRecursiveLock()
    private let droidCache = LRUCache<String, CachedBeatmap>(capacity: 20)
    private let standardCache = LRUCache<String, CachedBeatmap>(capacity: 20)

    /// Obtains a `Beatmap` from the cache, or parses it if it is not present.
    ///
    /// - Parameters:
    ///   - file: The URL of the beatmap file to obtain.
    ///   - withHitObjects: Whether to include hit objects in the returned `Beatmap`.
    ///   - mode: The `GameMode` of the beatmap to obtain. Defaults to `.standard`.
    /// - Returns: The `Beatmap` corresponding to the given file.
    public func getBeatmap(
        file: URL,
        withHitObjects: Bool,
        mode: GameMode = .standard
    ) throws -> Beatmap {
        // MD5 must be computed eagerly as it serves as the cache key.
        let md5 = try FileUtils.getMD5Checksum(file: file)
        if let cache = try getBeatmap(md5: md5, withHitObjects: withHitObjects, mode: mode) {
            return cache
        }
        return try cacheBeatmap(file: file, md5: md5, mode: mode, withHitObjects: withHitObjects).beatmap
    }

    /// Obtains a `Beatmap` from the cache, or parses it if it is not present.
    ///
    /// - Parameters:
    ///   - beatmapInfo: The `BeatmapInfo` of the beatmap to obtain.
    ///   - withHitObjects: Whether to include hit objects in the returned `Beatmap`.
    ///   - mode: The `GameMode` of the beatmap to obtain. Defaults to `.standard`.
    /// - Returns: The `Beatmap` corresponding to the given `BeatmapInfo`.
    public func getBeatmap(
        beatmapInfo: BeatmapInfo,
        withHitObjects: Bool,
        mode: GameMode = .standard
    ) throws -> Beatmap {
        if let cache = try getBeatmap(md5: beatmapInfo.md5, withHitObjects: withHitObjects, mode: mode) {
            return cache
        }

        let file = URL(fileURLWithPath: beatmapInfo.path)

        guard FileManager.default.fileExists(atPath: file.path) else {
            throw NSError(domain: "BeatmapCache", code: 404, userInfo: [NSLocalizedDescriptionKey: "Beatmap file does not exist: \\(beatmapInfo.path)"])
        }

        return try cacheBeatmap(file: file, md5: beatmapInfo.md5, mode: mode, withHitObjects: withHitObjects).beatmap
    }

    /// Invalidates the cache entry of a `Beatmap`.
    ///
    /// - Parameter md5: The MD5 hash of the beatmap to invalidate.
    public func invalidate(md5: String) {
        lock.lock()
        defer { lock.unlock() }
        droidCache.remove(md5)
        standardCache.remove(md5)
    }

    /// Invalidates the cache entry of a `Beatmap`.
    ///
    /// - Parameter beatmapInfo: The `BeatmapInfo` of the beatmap to invalidate.
    public func invalidate(beatmapInfo: BeatmapInfo) {
        invalidate(md5: beatmapInfo.md5)
    }

    /// Invalidates the cache entries of all `Beatmap`s in a `BeatmapSetInfo`.
    ///
    /// - Parameter beatmapSetInfo: The `BeatmapSetInfo` of the beatmaps to invalidate.
    public func invalidate(beatmapSetInfo: BeatmapSetInfo) {
        lock.lock()
        defer { lock.unlock() }
        for beatmap in beatmapSetInfo.beatmaps {
            droidCache.remove(beatmap.md5)
            standardCache.remove(beatmap.md5)
        }
    }

    /// Clears all entries from the cache.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        droidCache.clear()
        standardCache.clear()
    }

    private func getBeatmap(md5: String, withHitObjects: Bool, mode: GameMode) throws -> Beatmap? {
        var result: CacheLookupResult? = nil
        
        lock.lock()
        var cache = getCacheFor(mode: mode).get(md5)

        if cache == nil {
            let otherModeCache = mode == .droid ? standardCache : droidCache
            cache = otherModeCache.get(md5)

            if let cache = cache {
                if withHitObjects && !cache.withHitObjects {
                    // A beatmap without hit objects cannot be converted to one with hit objects.
                    result = nil
                } else {
                    // Found in the other mode's cache — needs conversion.
                    result = .needsConversion(cache.beatmap)
                }
            }
        }

        if result == nil, let cache = cache {
            if withHitObjects && !cache.withHitObjects {
                result = nil
            } else {
                // Cache hit for the requested mode — no conversion needed.
                result = .cacheHit(cache.beatmap)
            }
        }
        lock.unlock()

        switch result {
        case .cacheHit(let beatmap):
            return beatmap
        case .needsConversion(let beatmap):
            return try cacheBeatmap(beatmap: beatmap, mode: mode, withHitObjects: withHitObjects).beatmap
        case .none:
            return nil
        }
    }

    private func cacheBeatmap(file: URL, md5: String, mode: GameMode, withHitObjects: Bool) throws -> CachedBeatmap {
        let beatmap = try BeatmapParser(file: file, md5: md5).parse(withHitObjects: withHitObjects, mode: mode)
        return cacheBeatmap(beatmap: beatmap, mode: mode, withHitObjects: withHitObjects)
    }

    private func cacheBeatmap(beatmap: Beatmap, mode: GameMode, withHitObjects: Bool) -> CachedBeatmap {
        let converted = beatmap.convert(mode: mode)
        let cachedBeatmap = CachedBeatmap(beatmap: converted, withHitObjects: withHitObjects)

        lock.lock()
        defer { lock.unlock() }

        let cache = getCacheFor(mode: mode)
        let existing = cache.get(beatmap.md5)

        if let existing = existing, existing.withHitObjects, !withHitObjects {
            // A more complete beatmap was written by another thread while we were parsing; discard ours.
            return existing
        } else {
            cache.set(beatmap.md5, value: cachedBeatmap)
            return cachedBeatmap
        }
    }

    /// Returns the cache for the given `GameMode`.
    ///
    /// **Important:** Must only be called while holding `lock`.
    private func getCacheFor(mode: GameMode) -> LRUCache<String, CachedBeatmap> {
        switch mode {
        case .droid:
            return droidCache
        case .standard:
            return standardCache
        }
    }

    private struct CachedBeatmap {
        let beatmap: Beatmap
        let withHitObjects: Bool
    }

    /// Represents the result of a cache lookup in `getBeatmap`.
    private enum CacheLookupResult {
        case cacheHit(Beatmap)
        case needsConversion(Beatmap)
    }
}
