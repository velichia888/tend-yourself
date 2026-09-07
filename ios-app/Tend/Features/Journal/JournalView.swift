import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var store: JournalStore

    private static let needOptions = ["Rest", "Kindness", "Patience", "Connection", "Joy", "Confidence"]

    @State private var mood: Mood?
    @State private var selectedNeeds: Set<String> = []
    @State private var freeformText = ""
    @State private var gratitudeNote = ""
    @State private var energyLevel = 0.5
    @State private var sleepQuality = 0.5
    @State private var didSaveToday = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header
                    moodSection
                    needsSection
                    freeformSection
                    gratitudeSection
                    slidersSection
                    saveButton
                    footerNote
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear(perform: loadTodayIfPresent)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Journal")
                .font(Theme.Font.display(32))
                .foregroundStyle(Theme.ink)
            Text("A safe space for your thoughts, feelings, and growth.")
                .font(Theme.Font.body(13))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("How are you feeling today?")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
            HStack {
                ForEach(Mood.allCases, id: \.self) { option in
                    Button {
                        mood = option
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(mood == option ? FeatureCategory.mentalWellness.color : FeatureCategory.mentalWellness.softColor)
                                .frame(width: 40, height: 40)
                            Text(option.label)
                                .font(Theme.Font.body(10))
                                .foregroundStyle(Theme.inkSoft)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var needsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("What do you need more of today?")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
            FlowChips(options: Self.needOptions, selected: $selectedNeeds)
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var freeformSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("What's on your mind?")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
            TextEditor(text: $freeformText)
                .frame(minHeight: 100)
                .padding(Theme.Spacing.xs)
                .background(Theme.canvasSoft)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var gratitudeSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Today I'm grateful for...")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
            TextField("Add a gratitude note", text: $gratitudeNote)
                .padding(Theme.Spacing.sm)
                .background(Theme.canvasSoft)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var slidersSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Label("Energy level", systemImage: "bolt.fill").font(Theme.Font.headline(14))
                Slider(value: $energyLevel).tint(Theme.accent)
                HStack {
                    Text("Low").font(Theme.Font.body(11)).foregroundStyle(Theme.inkFaint)
                    Spacer()
                    Text("High").font(Theme.Font.body(11)).foregroundStyle(Theme.inkFaint)
                }
            }
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Label("Sleep last night", systemImage: "moon.fill").font(Theme.Font.headline(14))
                Slider(value: $sleepQuality).tint(Theme.accent)
                HStack {
                    Text("Poor").font(Theme.Font.body(11)).foregroundStyle(Theme.inkFaint)
                    Spacer()
                    Text("Great").font(Theme.Font.body(11)).foregroundStyle(Theme.inkFaint)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var saveButton: some View {
        Button {
            saveEntry()
        } label: {
            Label(didSaveToday ? "Saved" : "Save today's entry", systemImage: didSaveToday ? "checkmark" : "square.and.pencil")
                .font(Theme.Font.headline(16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.accent)
    }

    private var footerNote: some View {
        Text("Your feelings are valid. You're growing.")
            .font(Theme.Font.script(18))
            .foregroundStyle(Theme.inkSoft)
    }

    private func loadTodayIfPresent() {
        guard let entry = store.entry(for: Date()) else { return }
        mood = entry.mood
        selectedNeeds = Set(entry.needsTags)
        freeformText = entry.freeformText
        gratitudeNote = entry.gratitudeNote
        energyLevel = entry.energyLevel
        sleepQuality = entry.sleepQuality
        didSaveToday = true
    }

    private func saveEntry() {
        if let existing = store.entry(for: Date()) {
            store.deleteEntry(existing)
        }
        store.addEntry(JournalEntry(
            mood: mood,
            needsTags: Array(selectedNeeds),
            freeformText: freeformText,
            gratitudeNote: gratitudeNote,
            energyLevel: energyLevel,
            sleepQuality: sleepQuality
        ))
        didSaveToday = true
    }
}

/// A simple wrapping chip-selector, reused just here for the "needs"
/// tag picker.
private struct FlowChips: View {
    let options: [String]
    @Binding var selected: Set<String>
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.sm) {
            ForEach(options, id: \.self) { option in
                Button {
                    if selected.contains(option) { selected.remove(option) } else { selected.insert(option) }
                } label: {
                    Text(option)
                        .font(Theme.Font.body(13))
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(selected.contains(option) ? Theme.accent : Theme.canvasSoft)
                        .foregroundStyle(selected.contains(option) ? .white : Theme.ink)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    JournalView().environmentObject(JournalStore())
}
