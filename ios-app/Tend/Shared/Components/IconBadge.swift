import SwiftUI

/// A circular category-colored icon badge — the one visual atom reused
/// across glance-row cards, task rows, resource cells, and medication
/// rows. Category determines fill/icon color automatically unless
/// overridden.
struct IconBadge: View {
    var category: FeatureCategory
    var icon: String?
    var diameter: CGFloat = 40

    var body: some View {
        Circle()
            .fill(category.softColor)
            .frame(width: diameter, height: diameter)
            .overlay(
                Image(systemName: icon ?? category.icon)
                    .font(.system(size: diameter * 0.42, weight: .semibold))
                    .foregroundStyle(category.color)
            )
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.md) {
        ForEach(FeatureCategory.allCases) { category in
            IconBadge(category: category)
        }
    }
    .padding()
    .background(Theme.canvas)
}
