import Foundation

struct ResourceCategory: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let category: FeatureCategory
    /// Body text shown on the category's detail screen. Support/
    /// education framing only — never diagnostic or treatment language.
    let detailText: String
}
