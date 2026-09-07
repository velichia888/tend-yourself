import SwiftUI

/// The one reusable "icon badge + title/subtitle + trailing content"
/// row, reused (with different `trailing` content) for Home's glance
/// row, Task rows, Resource grid cells, and Medication rows.
struct IconBadgeCard<Trailing: View>: View {
    var category: FeatureCategory
    var icon: String?
    var title: String
    var subtitle: String?
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            IconBadge(category: category, icon: icon)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Font.headline(16))
                    .foregroundStyle(Theme.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Font.body(13))
                        .foregroundStyle(Theme.inkSoft)
                }
            }

            Spacer(minLength: Theme.Spacing.sm)
            trailing()
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

extension IconBadgeCard where Trailing == EmptyView {
    init(category: FeatureCategory, icon: String? = nil, title: String, subtitle: String? = nil) {
        self.init(category: category, icon: icon, title: title, subtitle: subtitle, trailing: { EmptyView() })
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.sm) {
        IconBadgeCard(category: .hydration, title: "Drink water", subtitle: "Nourish your body") {
            Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
        }
        IconBadgeCard(category: .medication, title: "Take medication", subtitle: "Keep you steady")
    }
    .padding()
    .background(Theme.canvas)
}
