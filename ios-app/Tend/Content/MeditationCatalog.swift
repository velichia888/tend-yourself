import Foundation

/// Static content, no persistence — mirrors the mockups' "More
/// meditations" list. Lives under Content/, not Services/, since this
/// is data, not a pure transformation.
enum MeditationCatalog {
    static let sessions: [MeditationSession] = [
        MeditationSession(
            id: "breathe",
            title: "Breathe",
            subtitle: "A few mindful breaths can change your whole day.",
            category: .breathing,
            availableDurationsMin: [1, 3, 5, 10]
        ),
        MeditationSession(
            id: "morning-reset",
            title: "Morning Reset",
            subtitle: "A fresh start for a brighter day",
            category: .morning,
            availableDurationsMin: [3, 5, 10]
        ),
        MeditationSession(
            id: "body-scan",
            title: "Body Scan",
            subtitle: "Tune in and feel more at ease",
            category: .bodyScan,
            availableDurationsMin: [5, 10]
        ),
        MeditationSession(
            id: "better-sleep",
            title: "Better Sleep",
            subtitle: "A calmer mind for a restful night",
            category: .sleep,
            availableDurationsMin: [5, 10]
        ),
        MeditationSession(
            id: "focus-clarity",
            title: "Focus & Clarity",
            subtitle: "Bring your attention back",
            category: .focus,
            availableDurationsMin: [1, 3, 5]
        ),
    ]
}
