import Foundation

/// Static support/education content — never diagnostic or treatment
/// language, per the mockups' "Resources should be presented as
/// support/education rather than diagnosis or treatment" framing.
enum ResourceCatalog {
    static let categories: [ResourceCategory] = [
        ResourceCategory(
            id: "overwhelmed",
            title: "I feel overwhelmed",
            subtitle: "Gentle tools for big feelings",
            icon: "cloud.fill",
            category: .mentalWellness,
            detailText: "When everything feels like too much at once, it can help to narrow your focus to just the next few minutes. Try naming what you're feeling without judging it, then pick one small, doable thing — a glass of water, a short walk, one slow breath."
        ),
        ResourceCategory(
            id: "grounding",
            title: "5-4-3-2-1 grounding",
            subtitle: "Be here now",
            icon: "leaf.fill",
            category: .wellness,
            detailText: "Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste. This shifts attention out of anxious thoughts and back into the present moment."
        ),
        ResourceCategory(
            id: "breathing-reset",
            title: "Breathing reset",
            subtitle: "Calm in a few minutes",
            icon: "wind",
            category: .hydration,
            detailText: "Slow, even breathing signals safety to your nervous system. Try the Breathe session under Meditate, or simply inhale for 4 counts, hold for 4, and exhale for 6."
        ),
        ResourceCategory(
            id: "sleep-support",
            title: "Sleep support",
            subtitle: "Rest a little easier",
            icon: "moon.stars.fill",
            category: .mentalWellness,
            detailText: "A consistent wind-down routine — dim lights, no screens, a calming sound or breath session — tells your body it's time to rest. The Better Sleep session under Meditate is built for this."
        ),
        ResourceCategory(
            id: "stress-burnout",
            title: "Stress & burnout",
            subtitle: "Tools to recharge",
            icon: "sun.max.fill",
            category: .dailyTasks,
            detailText: "Burnout often builds slowly. Notice patterns — skipped meals, lost sleep, constant urgency — and treat rest as a real task on your list, not something you earn after everything else is done."
        ),
        ResourceCategory(
            id: "find-help",
            title: "Find help",
            subtitle: "Local & online support",
            icon: "heart.fill",
            category: .selfCare,
            detailText: "A licensed therapist or counselor can offer support Tend isn't built to provide. Search Psychology Today's therapist directory, or ask your doctor for a referral, to find someone near you or available online."
        ),
    ]
}
