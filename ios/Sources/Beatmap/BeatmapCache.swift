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
}
