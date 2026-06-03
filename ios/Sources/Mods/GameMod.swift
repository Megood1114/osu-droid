import Foundation

/// Represents legacy game mod flags used for mod conversion.
/// These correspond to the bit flags used in the legacy replay/score format.
enum GameMod: String, CaseIterable {
    case noFail = "NF"
    case easy = "EZ"
    case hidden = "HD"
    case hardRock = "HR"
    case suddenDeath = "SD"
    case doubleTime = "DT"
    case relax = "RX"
    case halfTime = "HT"
    case nightCore = "NC"
    case flashlight = "FL"
    case autoplay = "AT"
    case autopilot = "AP"
    case perfect = "PF"
    case scoreV2 = "V2"
    case precise = "PR"
    case smallCircle = "SC"
    case reallyEasy = "RE"
    case difficultyAdjust = "DA"
}
