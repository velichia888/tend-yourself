import SwiftUI
import UIKit

struct ResourcesView: View {
    @EnvironmentObject private var supportPlanStore: SupportPlanStore
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                header

                LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                    ForEach(ResourceCatalog.categories) { category in
                        NavigationLink {
                            ResourceDetailView(category: category)
                        } label: {
                            categoryCell(category)
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    SupportPlanView()
                } label: {
                    IconBadgeCard(category: .wellness, icon: "leaf.fill", title: "My support plan", subtitle: "People, tools, and notes for tough days") {
                        Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
                    }
                }
                .buttonStyle(.plain)

                crisisCard
                supportContactsSection
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Resources")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Resources")
                .font(Theme.Font.display(30))
                .foregroundStyle(Theme.ink)
            Text("Support for wherever you are today.")
                .font(Theme.Font.body(14))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categoryCell(_ category: ResourceCategory) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: 22))
                .foregroundStyle(category.category.color)
            Text(category.title)
                .font(Theme.Font.headline(15))
                .foregroundStyle(Theme.ink)
            Text(category.subtitle)
                .font(Theme.Font.body(12))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(category.category.softColor)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))
    }

    /// A prominent, always-visible crisis card — but the rest of
    /// Resources stays supportive/educational rather than alarmist, so
    /// ordinary low moods don't constantly trigger crisis-level framing.
    private var crisisCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "heart.fill").foregroundStyle(Theme.danger)
                Text("Need immediate support?")
                    .font(Theme.Font.headline(16))
                    .foregroundStyle(Theme.ink)
            }
            Text("If you're in crisis or feel unsafe, please reach out. You're not alone.")
                .font(Theme.Font.body(13))
                .foregroundStyle(Theme.inkSoft)

            Button {
                callOrText988()
            } label: {
                Label("Call or text 988", systemImage: "phone.fill")
                    .font(Theme.Font.headline(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.danger)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.dangerSoft)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }

    private var supportContactsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Saved support contacts")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)

            if supportPlanStore.plan.contacts.isEmpty {
                Text("No saved contacts yet — add trusted people in My Support Plan.")
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(supportPlanStore.plan.contacts) { contact in
                    Button {
                        call(contact.phoneNumber)
                    } label: {
                        IconBadgeCard(category: .selfCare, icon: "person.fill", title: contact.name, subtitle: contact.relationship) {
                            Image(systemName: "phone.fill").foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func callOrText988() {
        if let url = URL(string: "tel://988") {
            UIApplication.shared.open(url)
        }
    }

    private func call(_ phoneNumber: String) {
        let digits = phoneNumber.filter(\.isNumber)
        if let url = URL(string: "tel://\(digits)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        ResourcesView().environmentObject(SupportPlanStore())
    }
}
