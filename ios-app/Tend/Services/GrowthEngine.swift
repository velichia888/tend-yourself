import Foundation

/// Pure, deterministic, disclosed formula — see docs/GROWTH.md. Never
/// randomized; always a function of real logged ml against the real
/// daily goal.
enum GrowthEngine {
    static func percentOfGoal(loggedML: Int, goalML: Int) -> Double {
        guard goalML > 0 else { return 0 }
        return (Double(loggedML) / Double(goalML)) * 100
    }

    static func stage(forPercent percent: Double) -> GrowthStage {
        switch percent {
        case ..<1: return .seed
        case 1..<25: return .sprout
        case 25..<50: return .stem
        case 50..<75: return .bud
        case 75..<100: return .openingBloom
        default: return .fullBloom
        }
    }

    static func stage(loggedML: Int, goalML: Int) -> GrowthStage {
        stage(forPercent: percentOfGoal(loggedML: loggedML, goalML: goalML))
    }

    /// A day plants a permanent flower in the Garden only at Full Bloom.
    static func dayQualifies(loggedML: Int, goalML: Int) -> Bool {
        stage(loggedML: loggedML, goalML: goalML) == .fullBloom
    }
}
