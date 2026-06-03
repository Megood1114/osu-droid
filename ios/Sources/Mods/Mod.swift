import Foundation

/// Represents a mod.
open class Mod: Hashable, Equatable {
    open var name: String { "" }
    open var acronym: String { "" }
    open var description: String { "" }
    open var type: ModType { .system }
    
    open var iconTextureNameSuffix: String {
        return name.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    public var iconTextureName: String {
        return "selection-mod-\(iconTextureNameSuffix)"
    }
    
    open var isRanked: Bool { return false }
    open var requiresConfiguration: Bool { return false }
    
    open var isRelevant: Bool {
        return !requiresConfiguration || !usesDefaultSettings
    }
    
    open var isUserPlayable: Bool { return true }
    open var isValidForMultiplayer: Bool { return true }
    open var isValidForMultiplayerAsFreeMod: Bool { return true }
    
    open var scoreMultiplier: Float { return 1.0 }
    
    open var migrationScoreMultiplier: Float {
        return scoreMultiplier
    }
    
    open var incompatibleMods: [AnyClass] {
        return []
    }
    
    // In a real port, we'd iterate over ModSetting properties.
    open var usesDefaultSettings: Bool {
        return true
    }
    
    public init() {}
    
    open func isCompatibleWith(other: Mod) -> Bool {
        let selfType = Swift.type(of: self)
        let otherType = Swift.type(of: other)
        
        let selfIncompatible = incompatibleMods.contains(where: { $0 == otherType })
        let otherIncompatible = other.incompatibleMods.contains(where: { $0 == selfType })
        
        return !selfIncompatible && !otherIncompatible
    }
    
    open func toAPIMod() -> APIMod {
        // Simplified mapping without settings
        return APIMod(acronym: acronym, settings: nil)
    }
    
    public static func == (lhs: Mod, rhs: Mod) -> Bool {
        if lhs === rhs { return true }
        return Swift.type(of: lhs) == Swift.type(of: rhs) // simplified equality
    }
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(isRanked)
        hasher.combine(name)
        hasher.combine(acronym)
        hasher.combine(iconTextureNameSuffix)
        hasher.combine(isRelevant)
        hasher.combine(isValidForMultiplayer)
        hasher.combine(isValidForMultiplayerAsFreeMod)
        // Ideally combine settings here as well
    }
    
    open var extraInformation: String {
        return ""
    }
    
    public var displayString: String {
        var str = acronym
        let info = extraInformation
        if !info.isEmpty {
            str += " (\(info))"
        }
        return str
    }
    
    open func copyFrom(_ other: Mod) {
        // Must be overriden in subclasses to copy settings
    }
    
    open func deepCopy() -> Mod {
        // Requires specific subclass implementation since Swift can't dynamically instantiate from type easily
        // A full port might require `required init()` or a cloning protocol.
        fatalError("deepCopy() must be implemented in subclasses")
    }
}