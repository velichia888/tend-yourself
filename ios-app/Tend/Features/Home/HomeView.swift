import SwiftUI

/// A single row in Home's chronological "Today's plan" list, merging
/// real data from Tasks and Medication (the two domains with genuine
/// per-item completion state). Meditation/Journal are surfaced as
/// static suggestions elsewhere on Home rather than fabricated
/// checklist rows, since neither persists a completion log to honor.
private struct TodayPlanItem: Identifiable {
    let id: String
    let time: Date
    let category: FeatureCategory
    let icon: String
    let title: String
    let subtitle: String
    let isComplete: Bool
    let toggle: () -> Void
}

struct HomeView: View {
    @EnvironmentObject private var waterStore: WaterLogStore
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var medicationStore: MedicationStore
    @EnvironmentObject private var journalStore: JournalStore

    @State private var showingHardDayMode = false

    private static let timeBlockDefaults: [TaskItem.TimeBlock: (hour: Int, minute: Int)] = [
        .morning: (9, 0), .afternoon: (14, 0), .evening: (19, 0),
    ]

    private var todaysMood: Mood? {
        journalStore.entry(for: Date())?.mood
    }

    private var planItems: [TodayPlanItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let taskItems: [TodayPlanItem] = taskStore.todayTasks.map { task in
            let components = task.reminderTime ?? DateComponents(
                hour: Self.timeBlockDefaults[task.timeBlock]?.hour,
                minute: Self.timeBlockDefaults[task.timeBlock]?.minute
            )
            var full = calendar.dateComponents([.year, .month, .day], from: today)
            full.hour = components.hour
            full.minute = components.minute
            let time = calendar.date(from: full) ?? today

            return TodayPlanItem(
                id: "task-\(task.id.uuidString)",
                time: time,
                category: .dailyTasks,
                icon: "checkmark.circle.fill",
                title: task.title,
                subtitle: task.subtitle ?? "A small step for today.",
                isComplete: task.isComplete,
                toggle: { taskStore.toggleComplete(task) }
            )
        }

        let medicationItems: [TodayPlanItem] = medicationStore.todaysDoses.map { dose in
            TodayPlanItem(
                id: "med-\(dose.id)",
                time: dose.scheduledFor,
                category: .medication,
                icon: "cross.case.fill",
                title: dose.medication.name,
                subtitle: dose.medication.dose,
                isComplete: medicationStore.status(for: dose) == .taken,
                toggle: {
                    let current = medicationStore.status(for: dose)
                    medicationStore.recordDose(dose, status: current == .taken ? .pending : .taken)
                }
            )
        }

        return (taskItems + medicationItems).sorted { $0.time < $1.time }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header
                    moodRow
                    glanceRow
                    encouragementCard
                    hardDayBanner
                    todaysPlanSection
                    resourcesLink
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            #if os(iOS)
	.navigationBarHidden(true)
	#endif
            .fullScreenCover(isPresented: $showingHardDayMode) {
                HardDayModeView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greeting)
                .font(Theme.Font.display(30))
                .foregroundStyle(Theme.ink)
            Text("Small steps make a big difference.")
                .font(Theme.Font.body(14))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case ..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var moodRow: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("How are you feeling today?")
                    .font(Theme.Font.headline(15))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("Take a moment").font(Theme.Font.body(12)).foregroundStyle(Theme.inkFaint)
            }
            HStack {
                ForEach(Mood.allCases, id: \.self) { option in
                    Button {
                        setTodayMood(option)
                    } label: {
                        Circle()
                            .fill(todaysMood == option ? FeatureCategory.mentalWellness.color : FeatureCategory.mentalWellness.softColor)
                            .frame(width: 36, height: 36)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var glanceRow: some View {
        HStack(spacing: Theme.Spacing.sm) {
            NavigationLink { WaterView() } label: {
                let percent = Int(min(waterStore.todayPercent, 100).rounded())
                glanceCard(category: .hydration, value: "\(percent)%", label: "Water")
            }
            NavigationLink { MedicationView() } label: {
                let (completed, total) = medicationStore.todaysCompletedCount
                glanceCard(category: .medication, value: "\(completed)/\(total)", label: "Meds")
            }
            NavigationLink { TasksView() } label: {
                let done = taskStore.todayTasks.filter(\.isComplete).count
                glanceCard(category: .dailyTasks, value: "\(done)/\(taskStore.todayTasks.count)", label: "Tasks")
            }
        }
        .buttonStyle(.plain)
    }

    private func glanceCard(category: FeatureCategory, value: String, label: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: category.icon).foregroundStyle(category.color)
            Text(value).font(Theme.Font.headline(18)).foregroundStyle(Theme.ink)
            Text(label).font(Theme.Font.body(12)).foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(category.softColor)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))
    }

    private var encouragementCard: some View {
        Text("\"You are enough, just as you are.\"")
            .font(Theme.Font.script(20))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.md)
            .background(FeatureCategory.wellness.softColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }

    private var hardDayBanner: some View {
        Button {
            showingHardDayMode = true
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hard Day Mode").font(Theme.Font.headline(16))
                    Text("Extra support for the tough days").font(Theme.Font.body(12))
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding(Theme.Spacing.md)
            .background(Theme.danger)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }

    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Today's plan")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)

            if planItems.isEmpty {
                Text("Nothing scheduled yet — add a task or medication to see it here.")
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(planItems) { item in
                    Button(action: item.toggle) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(item.time, format: .dateTime.hour().minute())
                                .font(Theme.Font.body(12))
                                .foregroundStyle(Theme.inkFaint)
                                .frame(width: 56, alignment: .leading)
                            IconBadge(category: item.category, icon: item.icon, diameter: 32)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title).font(Theme.Font.headline(14)).foregroundStyle(Theme.ink)
                                Text(item.subtitle).font(Theme.Font.body(12)).foregroundStyle(Theme.inkSoft)
                            }
                            Spacer()
                            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isComplete ? Theme.accent : Theme.inkFaint)
                        }
                        .padding(Theme.Spacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var resourcesLink: some View {
        NavigationLink {
            ResourcesView()
        } label: {
            IconBadgeCard(category: .mentalWellness, icon: "book.fill", title: "Resources", subtitle: "Support for wherever you are today") {
                Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
            }
        }
        .buttonStyle(.plain)
    }

    private func setTodayMood(_ mood: Mood) {
        if var existing = journalStore.entry(for: Date()) {
            journalStore.deleteEntry(existing)
            existing.mood = mood
            journalStore.addEntry(existing)
        } else {
            journalStore.addEntry(JournalEntry(mood: mood))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WaterLogStore())
        .environmentObject(TaskStore())
        .environmentObject(MedicationStore())
        .environmentObject(JournalStore())
}
