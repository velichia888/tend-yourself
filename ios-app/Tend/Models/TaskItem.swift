import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    enum TimeBlock: String, Codable, CaseIterable {
        case morning, afternoon, evening
    }

    enum Priority: String, Codable {
        case mustDo, niceToDo
    }

    enum Recurrence: String, Codable {
        case none, daily
    }

    let id: UUID
    /// Shared across every day's instance of a recurring task; nil for
    /// a one-off task. A recurring task's first instance sets this to
    /// its own `id`, marking it as the template every later day's
    /// instance is rolled forward from (see TaskEngine.rollForward).
    var templateID: UUID?
    var title: String
    var subtitle: String?
    var timeBlock: TimeBlock
    var priority: Priority
    var recurrence: Recurrence
    var dueDate: Date
    var completedAt: Date?
    /// Optional per-task reminder time (hour/minute only). Nil means no
    /// notification is scheduled for this task.
    var reminderTime: DateComponents?

    init(
        id: UUID = UUID(),
        templateID: UUID? = nil,
        title: String,
        subtitle: String? = nil,
        timeBlock: TimeBlock,
        priority: Priority,
        recurrence: Recurrence = .none,
        dueDate: Date,
        completedAt: Date? = nil,
        reminderTime: DateComponents? = nil
    ) {
        self.id = id
        self.templateID = templateID
        self.title = title
        self.subtitle = subtitle
        self.timeBlock = timeBlock
        self.priority = priority
        self.recurrence = recurrence
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.reminderTime = reminderTime
    }

    var isComplete: Bool { completedAt != nil }
}
