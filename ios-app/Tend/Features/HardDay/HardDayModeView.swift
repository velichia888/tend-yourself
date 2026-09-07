import SwiftUI

/// A simplified, reduced checklist for hard days — wired to the real
/// stores (checking off "drink water" actually logs water, etc.), never
/// a separate set of fake progress. Presented as a fullScreenCover
/// since it's meant to replace context entirely, not sit as a
/// dismissible quick modal.
struct HardDayModeView: View {
    @EnvironmentObject private var waterStore: WaterLogStore
    @EnvironmentObject private var medicationStore: MedicationStore
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var supportPlanStore: SupportPlanStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingBreathe = false

    private var nextPendingDose: MedicationEngine.Dose? {
        medicationStore.todaysDoses.first { medicationStore.status(for: $0) == .pending }
    }

    private var nextIncompleteTask: TaskItem? {
        taskStore.todayTasks.first { !$0.isComplete }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header

                    checklistRow(
                        category: .hydration,
                        icon: "drop.fill",
                        title: "Drink water",
                        subtitle: "A clearer you",
                        isDone: waterStore.todayTotalML > 0
                    ) {
                        waterStore.logWater(amountML: 250)
                    }

                    checklistRow(
                        category: .medication,
                        icon: "cross.case.fill",
                        title: "Take medication",
                        subtitle: nextPendingDose == nil ? "All caught up" : "Keep you steady",
                        isDone: nextPendingDose == nil,
                        isDisabled: nextPendingDose == nil
                    ) {
                        if let dose = nextPendingDose {
                            medicationStore.recordDose(dose, status: .taken)
                        }
                    }

                    NavigationLink {
                        MeditationPlayerView(session: MeditationCatalog.sessions[0], durationMinutes: 3)
                    } label: {
                        IconBadgeCard(category: .mentalWellness, icon: "wind", title: "3-minute breathe", subtitle: "Pause and reset") {
                            Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
                        }
                    }
                    .buttonStyle(.plain)

                    if let task = nextIncompleteTask {
                        checklistRow(
                            category: .dailyTasks,
                            icon: "checkmark.circle.fill",
                            title: task.title,
                            subtitle: "Progress still counts",
                            isDone: false
                        ) {
                            taskStore.toggleComplete(task)
                        }
                    } else {
                        IconBadgeCard(category: .dailyTasks, icon: "checkmark.circle.fill", title: "One small task", subtitle: "Nothing left today — that's okay")
                    }

                    NavigationLink {
                        ResourcesView()
                    } label: {
                        IconBadgeCard(category: .selfCare, icon: "person.2.fill", title: "Contact support", subtitle: "You're not alone") {
                            Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
                        }
                    }
                    .buttonStyle(.plain)

                    doneBanner
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Hard Day Mode")
                .font(Theme.Font.display(28))
                .foregroundStyle(Theme.ink)
            Text("Let's keep it simple today.")
                .font(Theme.Font.body(14))
                .foregroundStyle(Theme.inkSoft)
            Text("You don't have to do everything. Just a few things can make a difference.")
                .font(Theme.Font.body(13))
                .foregroundStyle(Theme.inkFaint)
                .multilineTextAlignment(.center)
            Text("This is a pause, not a failure.")
                .font(Theme.Font.script(20))
                .foregroundStyle(Theme.accent)
        }
        .frame(maxWidth: .infinity)
    }

    private func checklistRow(
        category: FeatureCategory,
        icon: String,
        title: String,
        subtitle: String,
        isDone: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            IconBadgeCard(category: category, icon: isDone ? "checkmark" : icon, title: title, subtitle: subtitle) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isDone ? Theme.accent : Theme.inkFaint)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var doneBanner: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("You've got this.")
                .font(Theme.Font.headline(16))
                .foregroundStyle(.white)
            Text("Brighter days are still ahead.")
                .font(Theme.Font.body(13))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.danger)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

#Preview {
    HardDayModeView()
        .environmentObject(WaterLogStore())
        .environmentObject(MedicationStore())
        .environmentObject(TaskStore())
        .environmentObject(SupportPlanStore())
}
