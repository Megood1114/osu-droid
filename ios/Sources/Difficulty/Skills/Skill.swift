import Foundation

open class Skill<TObject: DifficultyHitObject> {
    public let mods: [Mod]

    public init(mods: [Mod]) {
        self.mods = mods
    }

    open func process(current: TObject) {
        fatalError("process(current:) must be overridden")
    }

    open func difficultyValue() -> Double {
        fatalError("difficultyValue() must be overridden")
    }
}
