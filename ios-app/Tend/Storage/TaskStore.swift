import Foundation

/// Local-only persistence, mirroring WaterLogStore exactly: a plain JSON
/// array in the app's Documents directory, no backend.
@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let fileURL: URL
    private let calendar: Calendar

    init(fileURL: URL? = nil, calendar: Calendar = .current) {
        self.calendar = calendar
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documents.appendingPathComponent("tend_tasks.json")
        }
        load()
        rollForwardIfNeeded()
    }

    func addTask(
        title: String,
        subtitle: String? = nil,
        timeBlock: TaskItem.TimeBlock,
        priority: TaskItem.Priority,
        recurrence: TaskItem.Recurrence = .none,
        dueDate: Date = Date(),
        reminderTime: DateComponents? = nil
    ) {
        let id = UUID()
        let item = TaskItem(
            id: id,
            templateID: recurrence == .daily ? id : nil,
            title: title,
            subtitle: subtitle,
            timeBlock: timeBlock,
            priority: priority,
            recurrence: recurrence,
            dueDate: dueDate,
            reminderTime: reminderTime
        )
        tasks.append(item)
        save()
    }

    func toggleComplete(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].completedAt = tasks[index].isComplete ? nil : Date()
        save()
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func resetAllData() {
        tasks = []
        save()
    }

    var todayTasks: [TaskItem] {
        TaskEngine.tasks(due: Date(), in: tasks, calendar: calendar)
    }

    var thisWeekTasks: [TaskItem] {
        let range = TaskEngine.weekRange(containing: Date(), calendar: calendar)
        return tasks.filter { range.contains($0.dueDate) }
    }

    var completedTasks: [TaskItem] {
        tasks.filter(\.isComplete)
    }

    var todayGrouped: [TaskItem.TimeBlock: [TaskItem]] {
        TaskEngine.grouping(todayTasks)
    }

    var todayProgress: Double {
        TaskEngine.progress(for: todayTasks)
    }

    /// Materializes today's instance of every daily-recurring task, if
    /// it doesn't already exist. Called once at store init (app launch)
    /// — never backfills days the app wasn't opened on.
    private func rollForwardIfNeeded() {
        let newInstances = TaskEngine.rollForward(allTasks: tasks, to: Date(), calendar: calendar)
        guard !newInstances.isEmpty else { return }
        tasks.append(contentsOf: newInstances)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([TaskItem].self, from: data) {
            tasks = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(tasks) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
