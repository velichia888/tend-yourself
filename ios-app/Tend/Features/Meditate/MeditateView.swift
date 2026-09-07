import SwiftUI

struct MeditateView: View {
    @EnvironmentObject private var preferences: MeditationPreferencesStore
    @State private var selectedCategory: MeditationCategory?
    @State private var selectedSession = MeditationCatalog.sessions[0]
    @State private var selectedDuration: Int

    init() {
        _selectedDuration = State(initialValue: MeditationCatalog.sessions[0].availableDurationsMin.first ?? 3)
    }

    private var filteredSessions: [MeditationSession] {
        guard let selectedCategory else { return MeditationCatalog.sessions }
        return MeditationCatalog.sessions.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header
                    categoryChips
                    featuredSession
                    moreSessionsList
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Meditation")
                .font(Theme.Font.display(32))
                .foregroundStyle(Theme.ink)
            Text("A calmer mind, a brighter you.")
                .font(Theme.Font.script(18))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                chip(title: "All", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(MeditationCategory.allCases, id: \.self) { category in
                    chip(title: category.label, isSelected: selectedCategory == category) { selectedCategory = category }
                }
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Font.body(13))
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isSelected ? Theme.accent : Theme.surface)
                .foregroundStyle(isSelected ? .white : Theme.ink)
                .clipShape(Capsule())
        }
    }

    private var featuredSession: some View {
        let session = filteredSessions.first ?? MeditationCatalog.sessions[0]
        return VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(Theme.Font.display(28))
                    .foregroundStyle(Theme.ink)
                Text(session.subtitle)
                    .font(Theme.Font.body(14))
                    .foregroundStyle(Theme.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.lg)
            .background(FeatureCategory.mentalWellness.softColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))

            Text("Choose a duration")
                .font(Theme.Font.headline(14))
                .foregroundStyle(Theme.ink)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(session.availableDurationsMin, id: \.self) { minutes in
                    Button {
                        selectedDuration = minutes
                    } label: {
                        Text("\(minutes) min")
                            .font(Theme.Font.body(13))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(selectedDuration == minutes ? Theme.accent : Theme.surface)
                            .foregroundStyle(selectedDuration == minutes ? .white : Theme.ink)
                            .clipShape(Capsule())
                    }
                }
            }

            NavigationLink {
                MeditationPlayerView(session: session, durationMinutes: selectedDuration)
            } label: {
                Label("Start \(session.title)", systemImage: "play.fill")
                    .font(Theme.Font.headline(16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
    }

    private var moreSessionsList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("More meditations")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)

            ForEach(filteredSessions) { session in
                NavigationLink {
                    MeditationPlayerView(session: session, durationMinutes: session.availableDurationsMin.first ?? 3)
                } label: {
                    IconBadgeCard(category: .mentalWellness, icon: session.category.icon, title: session.title, subtitle: session.subtitle) {
                        HStack(spacing: Theme.Spacing.sm) {
                            if preferences.favoriteSessionIDs.contains(session.id) {
                                Image(systemName: "star.fill").foregroundStyle(FeatureCategory.dailyTasks.color)
                            }
                            Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    MeditateView().environmentObject(MeditationPreferencesStore())
}
