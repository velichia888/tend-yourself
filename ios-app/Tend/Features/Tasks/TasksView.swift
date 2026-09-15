import SwiftUI

struct TasksView: View {
    private enum Segment: String, CaseIterable { case today = "Today", week = "This Week", completed = "Completed" }

    @EnvironmentObject private var store: TaskStore
    @State private var segment: Segment = .today
    @State private var showingAddTask = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header
                    progressCard
                    segmentControl

                    switch segment {
                    case .today:
                        todayList
                    case .week:
                        weekList
                    case .completed:
                        completedList
                    }

                    addTaskButton
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            #if os(iOS)
	.navigationBarHidden(true)
	#endif
            .sheet(isPresented: $showingAddTask) {
                AddTaskView().environmentObject(store)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Tasks")
                .font(Theme.Font.display(34))
                .foregroundStyle(Theme.ink)
            Text("SMALL STEPS, BIGGER DAYS")
                .font(Theme.Font.body(11))
                .foregroundStyle(Theme.inkFaint)
                .tracking(1.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressCard: some View {
        let done = store.todayTasks.filter(\.isComplete).count
        let total = store.todayTasks.count
        return HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle().stroke(Theme.canvasSoft, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: store.todayProgress)
                    .stroke(FeatureCategory.dailyTasks.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(done) of \(total)")
                    .font(Theme.Font.headline(14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 4) {
                Text(total == 0 ? "Nothing due today" : "You're doing great!")
                    .font(Theme.Font.headline(16))
                    .foregroundStyle(Theme.ink)
                Text("Small steps make a big difference.")
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var segmentControl: some View {
        Picker("", selection: $segment) {
            ForEach(Segment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
    }

    private var todayList: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(TaskItem.TimeBlock.allCases, id: \.self) { block in
                if let tasks = store.todayGrouped[block], !tasks.isEmpty {
                    timeBlockSection(block, tasks: tasks)
                }
            }
            if store.todayTasks.isEmpty {
                emptyState(text: "No tasks yet today. Add one below to get started.")
            }
        }
    }

    private func timeBlockSection(_ block: TaskItem.TimeBlock, tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(block.rawValue.capitalized)
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)

            ForEach(tasks) { task in
                taskRow(task)
            }
        }
    }

    private func taskRow(_ task: TaskItem) -> some View {
        IconBadgeCard(
            category: .dailyTasks,
            icon: task.isComplete ? "checkmark" : nil,
            title: task.title,
            subtitle: task.subtitle
        ) {
            HStack(spacing: Theme.Spacing.sm) {
                Text(task.priority == .mustDo ? "Must do" : "Nice to do")
                    .font(Theme.Font.body(11))
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(task.priority == .mustDo ? FeatureCategory.selfCare.softColor : FeatureCategory.hydration.softColor)
                    .clipShape(Capsule())

                Button {
                    store.toggleComplete(task)
                } label: {
                    Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(task.isComplete ? Theme.accent : Theme.inkFaint)
                }
                .accessibilityLabel(task.isComplete ? "Mark incomplete" : "Mark complete")
            }
        }
    }

    private var weekList: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if store.thisWeekTasks.isEmpty {
                emptyState(text: "Nothing on the calendar for this week yet.")
            } else {
                ForEach(store.thisWeekTasks) { taskRow($0) }
            }
        }
    }

    private var completedList: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if store.completedTasks.isEmpty {
                emptyState(text: "Nothing completed yet — progress still counts, even the small stuff.")
            } else {
                ForEach(store.completedTasks) { taskRow($0) }
            }
        }
    }

    private func emptyState(text: String) -> some View {
        Text(text)
            .font(Theme.Font.body(14))
            .foregroundStyle(Theme.inkSoft)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
    }

    private var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Label("Add a Task", systemImage: "plus")
                .font(Theme.Font.headline(16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.accent)
    }
}

#Preview {
    TasksView().environmentObject(TaskStore())
}
