import SwiftUI

struct ResourceDetailView: View {
    @EnvironmentObject private var supportPlanStore: SupportPlanStore
    let category: ResourceCategory

    private var isSaved: Bool {
        supportPlanStore.plan.savedTechniqueIDs.contains(category.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(category.category.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.title)
                            .font(Theme.Font.display(24))
                            .foregroundStyle(Theme.ink)
                        Text(category.subtitle)
                            .font(Theme.Font.body(13))
                            .foregroundStyle(Theme.inkSoft)
                    }
                }

                Text(category.detailText)
                    .font(Theme.Font.body(15))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(4)

                Button {
                    supportPlanStore.toggleTechnique(category.id)
                } label: {
                    Label(isSaved ? "Saved to your support plan" : "Save to my support plan", systemImage: isSaved ? "checkmark" : "plus")
                        .font(Theme.Font.headline(15))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(isSaved ? Theme.success : Theme.accent)
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ResourceDetailView(category: ResourceCatalog.categories[0])
            .environmentObject(SupportPlanStore())
    }
}
