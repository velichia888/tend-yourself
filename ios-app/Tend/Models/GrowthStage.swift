import Foundation

/// See docs/GROWTH.md for the full disclosed formula. Ordered seed to
/// full bloom so `<`/`>=` comparisons on the raw enum are meaningful.
enum GrowthStage: Int, CaseIterable, Comparable {
    case seed
    case sprout
    case stem
    case bud
    case openingBloom
    case fullBloom

    static func < (lhs: GrowthStage, rhs: GrowthStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .stem: return "Stem"
        case .bud: return "Bud"
        case .openingBloom: return "Opening Bloom"
        case .fullBloom: return "Full Bloom"
        }
    }

    /// 0...1 fraction used to size the drawn flower head — not the same
    /// number as percentOfGoal (which can exceed 100), just a rendering
    /// hint per discrete stage.
    var bloomFraction: Double {
        switch self {
        case .seed: return 0.0
        case .sprout: return 0.2
        case .stem: return 0.4
        case .bud: return 0.6
        case .openingBloom: return 0.8
        case .fullBloom: return 1.0
        }
    }
}
