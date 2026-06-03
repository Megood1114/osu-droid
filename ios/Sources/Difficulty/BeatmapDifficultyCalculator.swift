import Foundation

private let droidDifficultyCalculator = DroidDifficultyCalculator()
private let standardDifficultyCalculator = StandardDifficultyCalculator()

/// A helper class for operations relating to difficulty and performance calculation.
public enum BeatmapDifficultyCalculator {
    
    /// Cache of difficulty calculations, mapped by MD5 hash of a beatmap.
    private static let difficultyCacheManager = LRUCache<String, BeatmapDifficultyCacheManager>(capacity: 10)

    /// Constructs a `DroidPerformanceCalculationParameters` from an `IBeatmap` and `StatisticV2`.
    public static func constructDroidPerformanceParameters(beatmap: IBeatmap, stat: StatisticV2?) -> DroidPerformanceCalculationParameters? {
        guard let stat = stat else { return nil }
        let params = DroidPerformanceCalculationParameters()
        params.populate(beatmap: beatmap, stat: stat)
        return params
    }

    /// Constructs a `StandardPerformanceCalculationParameters` from an `IBeatmap` and `StatisticV2`.
    public static func constructStandardPerformanceParameters(beatmap: IBeatmap, stat: StatisticV2?) -> StandardPerformanceCalculationParameters? {
        guard let stat = stat else { return nil }
        let params = StandardPerformanceCalculationParameters()
        params.populate(beatmap: beatmap, stat: stat)
        return params
    }

    /// Calculates the difficulty of a `Beatmap` with specific `Mod`s.
    public static func calculateDroidDifficulty(beatmap: Beatmap, mods: [Mod]? = nil) -> DroidDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidDifficultyCache(mods: mods, forReplay: false) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculate(beatmap: beatmap, mods: mods)
        addCache(beatmap: beatmap, attributes: attributes, forReplay: false)
        return attributes
    }

    /// Calculates the difficulty of a `DroidPlayableBeatmap`.
    public static func calculateDroidDifficulty(beatmap: DroidPlayableBeatmap) -> DroidDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidDifficultyCache(mods: Array(beatmap.mods.values), forReplay: false) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculate(beatmap: beatmap)
        addCache(beatmap: beatmap, attributes: attributes, forReplay: false)
        return attributes
    }

    /// Calculates the difficulty of a `Beatmap` with specific `Mod`s. The result of this calculation can be used in replay-based performance calculations.
    public static func calculateDroidDifficultyForReplay(beatmap: Beatmap, mods: [Mod]? = nil) -> DroidDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidDifficultyCache(mods: mods, forReplay: true) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculate(beatmap: beatmap, mods: mods)
        addCache(beatmap: beatmap, attributes: attributes, forReplay: true)
        return attributes
    }

    /// Calculates the difficulty of a `DroidPlayableBeatmap`. The result of this calculation can be used in replay-based performance calculations.
    public static func calculateDroidDifficultyForReplay(beatmap: DroidPlayableBeatmap) -> DroidDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidDifficultyCache(mods: Array(beatmap.mods.values), forReplay: true) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculate(beatmap: beatmap)
        addCache(beatmap: beatmap, attributes: attributes, forReplay: true)
        return attributes
    }

    /// Calculates the difficulty of a `Beatmap` with specific `Mod`s, returning an array of `TimedDifficultyAttributes`
    public static func calculateDroidTimedDifficulty(beatmap: Beatmap, mods: [Mod]? = nil) -> [TimedDifficultyAttributes<DroidDifficultyAttributes>] {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidTimedDifficultyCache(mods: mods) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculateTimed(beatmap: beatmap, mods: mods)
        addCache(beatmap: beatmap, attributes: attributes)
        return attributes
    }

    /// Calculates the difficulty of a `DroidPlayableBeatmap`, returning an array of `TimedDifficultyAttributes`
    public static func calculateDroidTimedDifficulty(beatmap: DroidPlayableBeatmap) -> [TimedDifficultyAttributes<DroidDifficultyAttributes>] {
        if let cached = difficultyCacheManager[beatmap.md5]?.getDroidTimedDifficultyCache(mods: Array(beatmap.mods.values)) {
            return cached
        }
        let attributes = droidDifficultyCalculator.calculateTimed(beatmap: beatmap)
        addCache(beatmap: beatmap, attributes: attributes)
        return attributes
    }

    /// Calculates the difficulty of a `Beatmap` with specific `Mod`s.
    public static func calculateStandardDifficulty(beatmap: Beatmap, mods: [Mod]? = nil) -> StandardDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getStandardDifficultyCache(mods: mods) {
            return cached
        }
        let attributes = standardDifficultyCalculator.calculate(beatmap: beatmap, mods: mods)
        addCache(beatmap: beatmap, attributes: attributes)
        return attributes
    }

    /// Calculates the difficulty of a `StandardPlayableBeatmap`.
    public static func calculateStandardDifficulty(beatmap: StandardPlayableBeatmap) -> StandardDifficultyAttributes {
        if let cached = difficultyCacheManager[beatmap.md5]?.getStandardDifficultyCache(mods: Array(beatmap.mods.values)) {
            return cached
        }
        let attributes = standardDifficultyCalculator.calculate(beatmap: beatmap)
        addCache(beatmap: beatmap, attributes: attributes)
        return attributes
    }

    /// Calculates the difficulty of a `Beatmap` with specific `Mod`s, returning an array of `TimedDifficultyAttributes`
    public static func calculateStandardTimedDifficulty(beatmap: Beatmap, mods: [Mod]? = nil) -> [TimedDifficultyAttributes<StandardDifficultyAttributes>] {
        return calculateStandardTimedDifficulty(beatmap: beatmap.createStandardPlayableBeatmap(mods: mods))
    }

    /// Calculates the difficulty of a `StandardPlayableBeatmap`, returning an array of `TimedDifficultyAttributes`
    public static func calculateStandardTimedDifficulty(beatmap: StandardPlayableBeatmap) -> [TimedDifficultyAttributes<StandardDifficultyAttributes>] {
        if let cached = difficultyCacheManager[beatmap.md5]?.getStandardTimedDifficultyCache(mods: Array(beatmap.mods.values)) {
            return cached
        }
        let attributes = standardDifficultyCalculator.calculateTimed(beatmap: beatmap)
        addCache(beatmap: beatmap, attributes: attributes)
        return attributes
    }

    /// Calculates the performance of a `DroidDifficultyAttributes`.
    public static func calculateDroidPerformance(beatmap: IBeatmap, attributes: DroidDifficultyAttributes, stat: StatisticV2) -> DroidPerformanceAttributes {
        return calculateDroidPerformance(attributes: attributes, parameters: constructDroidPerformanceParameters(beatmap: beatmap, stat: stat))
    }

    /// Calculates the performance of a `DroidDifficultyAttributes`.
    public static func calculateDroidPerformance(attributes: DroidDifficultyAttributes, parameters: DroidPerformanceCalculationParameters? = nil) -> DroidPerformanceAttributes {
        return DroidPerformanceCalculator(attributes: attributes).calculate(parameters: parameters)
    }

    /// Calculates the performance of a `DroidDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateDroidPerformance(beatmap: Beatmap, attributes: DroidDifficultyAttributes, replay: Replay, stat: StatisticV2? = nil) -> DroidPerformanceAttributes {
        return calculateDroidPerformance(beatmap: beatmap, attributes: attributes, replay: replay, parameters: constructDroidPerformanceParameters(beatmap: beatmap, stat: stat))
    }

    /// Calculates the performance of a `DroidDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateDroidPerformance(beatmap: Beatmap, attributes: DroidDifficultyAttributes, replay: Replay, parameters: DroidPerformanceCalculationParameters? = nil) -> DroidPerformanceAttributes {
        return calculateDroidPerformance(beatmap: beatmap.createDroidPlayableBeatmap(mods: attributes.mods), attributes: attributes, replay: replay, parameters: parameters)
    }

    /// Calculates the performance of a `DroidDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateDroidPerformance(beatmap: DroidPlayableBeatmap, attributes: DroidDifficultyAttributes, replay: Replay, stat: StatisticV2? = nil) -> DroidPerformanceAttributes {
        return calculateDroidPerformance(beatmap: beatmap, attributes: attributes, replay: replay, parameters: constructDroidPerformanceParameters(beatmap: beatmap, stat: stat))
    }

    /// Calculates the performance of a `DroidDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateDroidPerformance(beatmap: DroidPlayableBeatmap, attributes: DroidDifficultyAttributes, replay: Replay, parameters: DroidPerformanceCalculationParameters? = nil) -> DroidPerformanceAttributes {
        let actualParameters = parameters ?? DroidPerformanceCalculationParameters()
        let cursorGroups = createCursorGroups(cursorMoves: replay.cursorMoves)

        actualParameters.tapPenalty = ThreeFingerChecker(
            beatmap: beatmap, attributes: attributes, replayVersion: replay.replayVersion, cursorGroups: cursorGroups, objectData: replay.objectData
        ).calculatePenalty()

        actualParameters.sliderCheesePenalty = SliderCheeseChecker(
            beatmap: beatmap, attributes: attributes, replayVersion: replay.replayVersion, cursorGroups: cursorGroups, objectData: replay.objectData
        ).calculatePenalty()

        actualParameters.populateNestedSliderObjectParameters(beatmap: beatmap, replayObjectData: replay.objectData)

        return DroidPerformanceCalculator(attributes: attributes).calculate(parameters: actualParameters)
    }

    /// Calculates the performance of a `StandardDifficultyAttributes`.
    public static func calculateStandardPerformance(beatmap: IBeatmap, attributes: StandardDifficultyAttributes, stat: StatisticV2) -> StandardPerformanceAttributes {
        return calculateStandardPerformance(attributes: attributes, parameters: constructStandardPerformanceParameters(beatmap: beatmap, stat: stat))
    }

    /// Calculates the performance of a `StandardDifficultyAttributes`.
    public static func calculateStandardPerformance(attributes: StandardDifficultyAttributes, parameters: StandardPerformanceCalculationParameters? = nil) -> StandardPerformanceAttributes {
        return StandardPerformanceCalculator(attributes: attributes).calculate(parameters: parameters)
    }

    /// Calculates the performance of a `StandardDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateStandardPerformance(beatmap: StandardPlayableBeatmap, attributes: StandardDifficultyAttributes, replayObjectData: [ReplayObjectData], stat: StatisticV2? = nil) -> StandardPerformanceAttributes {
        return calculateStandardPerformance(beatmap: beatmap, attributes: attributes, replayObjectData: replayObjectData, parameters: constructStandardPerformanceParameters(beatmap: beatmap, stat: stat))
    }

    /// Calculates the performance of a `StandardDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateStandardPerformance(beatmap: Beatmap, attributes: StandardDifficultyAttributes, replayObjectData: [ReplayObjectData], parameters: StandardPerformanceCalculationParameters? = nil) -> StandardPerformanceAttributes {
        return calculateStandardPerformance(beatmap: beatmap.createStandardPlayableBeatmap(mods: attributes.mods), attributes: attributes, replayObjectData: replayObjectData, parameters: parameters)
    }

    /// Calculates the performance of a `StandardDifficultyAttributes` and applies necessary adjustments using replay data.
    public static func calculateStandardPerformance(beatmap: StandardPlayableBeatmap, attributes: StandardDifficultyAttributes, replayObjectData: [ReplayObjectData], parameters: StandardPerformanceCalculationParameters? = nil) -> StandardPerformanceAttributes {
        let actualParameters = parameters ?? StandardPerformanceCalculationParameters()
        actualParameters.populateNestedSliderObjectParameters(beatmap: beatmap, replayObjectData: replayObjectData)
        return StandardPerformanceCalculator(attributes: attributes).calculate(parameters: actualParameters)
    }

    /// Clears all entries from the difficulty cache.
    public static func clearCache() {
        difficultyCacheManager.clear()
    }

    private static func addCache(beatmap: IBeatmap, attributes: DroidDifficultyAttributes, forReplay: Bool) {
        let manager = difficultyCacheManager.getOrCreate(key: beatmap.md5, fallback: { BeatmapDifficultyCacheManager() })
        manager.addCache(attributes: attributes, forReplay: forReplay)
    }

    private static func addCache(beatmap: IBeatmap, attributes: StandardDifficultyAttributes) {
        let manager = difficultyCacheManager.getOrCreate(key: beatmap.md5, fallback: { BeatmapDifficultyCacheManager() })
        manager.addCache(attributes: attributes)
    }

    private static func addCache(beatmap: IBeatmap, attributes: [TimedDifficultyAttributes<DroidDifficultyAttributes>]) {
        let manager = difficultyCacheManager.getOrCreate(key: beatmap.md5, fallback: { BeatmapDifficultyCacheManager() })
        manager.addCache(attributes: attributes)
    }

    private static func addCache(beatmap: IBeatmap, attributes: [TimedDifficultyAttributes<StandardDifficultyAttributes>]) {
        let manager = difficultyCacheManager.getOrCreate(key: beatmap.md5, fallback: { BeatmapDifficultyCacheManager() })
        manager.addCache(attributes: attributes)
    }
}

/// A cache holder for a `Beatmap`.
private class BeatmapDifficultyCacheManager {
    private let droidAttributeCache = LRUCache<Set<Mod>, BeatmapDifficultyCache<DroidDifficultyAttributes>>(capacity: 5)
    private let droidTimedAttributeCache = LRUCache<Set<Mod>, BeatmapDifficultyCache<[TimedDifficultyAttributes<DroidDifficultyAttributes>]>>(capacity: 3)
    private let standardAttributeCache = LRUCache<Set<Mod>, BeatmapDifficultyCache<StandardDifficultyAttributes>>(capacity: 5)
    private let standardTimedAttributeCache = LRUCache<Set<Mod>, BeatmapDifficultyCache<[TimedDifficultyAttributes<StandardDifficultyAttributes>]>>(capacity: 3)

    func addCache(attributes: DroidDifficultyAttributes, forReplay: Bool) {
        addCache(mods: attributes.mods, mode: .droid, cache: attributes, cacheMap: droidAttributeCache, forReplay: forReplay)
    }

    func addCache(attributes: StandardDifficultyAttributes) {
        addCache(mods: attributes.mods, mode: .standard, cache: attributes, cacheMap: standardAttributeCache, forReplay: false)
    }

    func addCache(attributes: [TimedDifficultyAttributes<DroidDifficultyAttributes>]) {
        if let first = attributes.first {
            addCache(mods: first.attributes.mods, mode: .droid, cache: attributes, cacheMap: droidTimedAttributeCache, forReplay: false)
        }
    }

    func addCache(attributes: [TimedDifficultyAttributes<StandardDifficultyAttributes>]) {
        if let first = attributes.first {
            addCache(mods: first.attributes.mods, mode: .standard, cache: attributes, cacheMap: standardTimedAttributeCache, forReplay: false)
        }
    }

    func getDroidDifficultyCache(mods: [Mod]?, forReplay: Bool) -> DroidDifficultyAttributes? {
        return getCache(mods: mods, mode: .droid, cacheMap: droidAttributeCache, forReplay: forReplay)
    }

    func getDroidTimedDifficultyCache(mods: [Mod]?) -> [TimedDifficultyAttributes<DroidDifficultyAttributes>]? {
        return getCache(mods: mods, mode: .droid, cacheMap: droidTimedAttributeCache, forReplay: false)
    }

    func getStandardDifficultyCache(mods: [Mod]?) -> StandardDifficultyAttributes? {
        return getCache(mods: mods, mode: .standard, cacheMap: standardAttributeCache, forReplay: false)
    }

    func getStandardTimedDifficultyCache(mods: [Mod]?) -> [TimedDifficultyAttributes<StandardDifficultyAttributes>]? {
        return getCache(mods: mods, mode: .standard, cacheMap: standardTimedAttributeCache, forReplay: false)
    }

    var isEmpty: Bool {
        return droidAttributeCache.isEmpty && droidTimedAttributeCache.isEmpty &&
               standardAttributeCache.isEmpty && standardTimedAttributeCache.isEmpty
    }

    private func addCache<T>(mods: [Mod]?, mode: GameMode, cache: T, cacheMap: LRUCache<Set<Mod>, BeatmapDifficultyCache<T>>, forReplay: Bool) {
        let processedMods = Set(processMods(mods: mods, mode: mode))
        let existing = cacheMap[processedMods]

        if !forReplay && existing != nil && existing!.forReplay {
            return
        }

        cacheMap[processedMods] = BeatmapDifficultyCache(cache: cache, forReplay: forReplay)
    }

    private func getCache<T>(mods: [Mod]?, mode: GameMode, cacheMap: LRUCache<Set<Mod>, BeatmapDifficultyCache<T>>, forReplay: Bool) -> T? {
        let processedMods = Set(processMods(mods: mods, mode: mode))
        let cache = cacheMap[processedMods]

        if forReplay && cache?.forReplay != true {
            return nil
        }

        return cache?.cache
    }

    private func processMods(mods: [Mod]?, mode: GameMode) -> [Mod] {
        guard let mods = mods else { return [] }
        switch mode {
        case .droid:
            return droidDifficultyCalculator.retainDifficultyAdjustmentMods(mods: mods)
        case .standard:
            return standardDifficultyCalculator.retainDifficultyAdjustmentMods(mods: mods)
        }
    }
}

/// Represents a beatmap difficulty cache.
private struct BeatmapDifficultyCache<T> {
    let cache: T
    let forReplay: Bool
}

private class LRUCache<K: Hashable, V> {
    private let capacity: Int
    private var cache: [K: V] = [:]
    private var order: [K] = []

    init(capacity: Int) {
        self.capacity = capacity
    }

    subscript(key: K) -> V? {
        get {
            if let value = cache[key] {
                if let index = order.firstIndex(of: key) {
                    order.remove(at: index)
                    order.append(key)
                }
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                if cache[key] == nil {
                    if order.count >= capacity {
                        let lru = order.removeFirst()
                        cache.removeValue(forKey: lru)
                    }
                    order.append(key)
                } else {
                    if let index = order.firstIndex(of: key) {
                        order.remove(at: index)
                        order.append(key)
                    }
                }
                cache[key] = newValue
            } else {
                cache.removeValue(forKey: key)
                if let index = order.firstIndex(of: key) {
                    order.remove(at: index)
                }
            }
        }
    }

    func clear() {
        cache.removeAll()
        order.removeAll()
    }
    
    var isEmpty: Bool {
        return cache.isEmpty
    }

    func getOrCreate(key: K, fallback: () -> V) -> V {
        if let value = self[key] {
            return value
        } else {
            let newValue = fallback()
            self[key] = newValue
            return newValue
        }
    }
}
