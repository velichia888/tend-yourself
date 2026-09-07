import SwiftUI

/// The category-color system from the "Small Steps, Brighter Days"
/// mockups: every feature domain gets one consistent color + icon,
/// reused everywhere that domain shows up (Home's glance row, task
/// rows, resource grid cells, medication rows, tab icons).
enum FeatureCategory: String, CaseIterable, Identifiable {
    case wellness
    case selfCare
    case hydration
    case mentalWellness
    case dailyTasks
    case medication

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wellness: return "Wellness"
        case .selfCare: return "Self Care"
        case .hydration: return "Water"
        case .mentalWellness: return "Meditate"
        case .dailyTasks: return "Tasks"
        case .medication: return "Medication"
        }
    }

    var icon: String {
        switch self {
        case .wellness: return "leaf.fill"
        case .selfCare: return "heart.fill"
        case .hydration: return "drop.fill"
        case .mentalWellness: return "wind"
        case .dailyTasks: return "checkmark.circle.fill"
        case .medication: return "cross.case.fill"
        }
    }

    /// The saturated tone — icons, progress fills, active states.
    var color: Color {
        switch self {
        case .wellness: return Color(red: 0.4667, green: 0.6392, blue: 0.5137)      // sage #77A383
        case .selfCare: return Color(red: 0.9333, green: 0.5137, blue: 0.4275)      // coral #EE836D
        case .hydration: return Color(red: 0.3608, green: 0.6784, blue: 0.8353)     // sky #5CADD5
        case .mentalWellness: return Color(red: 0.6588, green: 0.5804, blue: 0.8353) // lavender #A894D5
        case .dailyTasks: return Color(red: 0.9412, green: 0.7255, blue: 0.302)     // golden yellow #F0B94D
        case .medication: return Color(red: 0.9490, green: 0.6588, blue: 0.5451)    // soft peach #F2A88B
        }
    }

    /// The pale tint — badge backgrounds, chip fills.
    var softColor: Color {
        switch self {
        case .wellness: return Color(red: 0.8627, green: 0.9333, blue: 0.8784)      // #DCEEE0
        case .selfCare: return Color(red: 0.9882, green: 0.8902, blue: 0.8627)      // #FCE3DC
        case .hydration: return Color(red: 0.8627, green: 0.9333, blue: 0.9686)     // #DCEEF7
        case .mentalWellness: return Color(red: 0.9176, green: 0.8902, blue: 0.9608) // #EAE3F5
        case .dailyTasks: return Color(red: 0.9843, green: 0.9176, blue: 0.7961)    // #FBEACB
        case .medication: return Color(red: 0.9843, green: 0.8902, blue: 0.8392)    // #FBE3D6
        }
    }
}
