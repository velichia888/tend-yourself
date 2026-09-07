import Foundation

enum MeditationCategory: String, CaseIterable, Codable {
    case breathing, sleep, bodyScan, focus, morning

    var label: String {
        switch self {
        case .breathing: return "Breathing"
        case .sleep: return "Sleep"
        case .bodyScan: return "Body Scan"
        case .focus: return "Focus"
        case .morning: return "Morning"
        }
    }

    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .sleep: return "moon.fill"
        case .bodyScan: return "figure.mind.and.body"
        case .focus: return "leaf.fill"
        case .morning: return "sun.max.fill"
        }
    }
}

struct MeditationSession: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let category: MeditationCategory
    let availableDurationsMin: [Int]
}
