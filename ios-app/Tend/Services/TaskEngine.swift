import Foundation

/// Pure, deterministic task-list logic — grouping, progress, and
/// recurrence expansion — kept independent of TaskStore/SwiftUI, same
/// precedent as GrowthEngine/GardenEngine.
enum TaskEngine {
    static func tasks(due day: Date, in tasks: [TaskItem], calendar: Calendar = .current) -> [TaskItem] {
        let start = calendar.startOfDay(for: day)
        return tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: start) }
    }

    static func grouping(_ tasks: [TaskItem]) -> [TaskItem.TimeBlock: [TaskItem]] {
        Dictionary(grouping: tasks, by: \.timeBlock)
    }

    static func progress(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter(\.isComplete).count
        return Double(completed) / Double(tasks.count)
    }

    static func weekRange(containing date: Date, calendar: Calendar = .current) -> ClosedRange<Date> {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return date...date
        }
        let end = calendar.date(byAdding: .second, value: -1, to: interval.end) ?? interval.end
        return interval.start...end
    }

    /// Recurring-task expansion: for each daily-recurring template not
    /// yet represented on `day`, produce a fresh instance due that day.
    /// Deliberately never backfills earlier missed days — only ever
    /// materializes `day`'s instance, so a multi-day gap never builds an
    /// overwhelming backlog.
    static func rollForward(allTasks: [TaskItem], to day: Date, calendar: Calendar = .current) -> [TaskItem] {
        let dayStart = calendar.startOfDay(for: day)

        let templateIDs = Set(allTasks.compactMap { $0.recurrence == .daily ? $0.templateID : nil })
        var newInstances: [TaskItem] = []

        for templateID in templateIDs {
            let instances = allTasks.filter { $0.templateID == templateID }
            let alreadyPresentToday = instances.contains {
                calendar.isDate($0.dueDate, inSameDayAs: dayStart)
            }
            guard !alreadyPresentToday else { continue }

            guard let mostRecent = instances.max(by: { $0.dueDate < $1.dueDate }) else { continue }
            newInstances.append(TaskItem(
                templateID: templateID,
                title: mostRecent.title,
                subtitle: mostRecent.subtitle,
                timeBlock: mostRecent.timeBlock,
                priority: mostRecent.priority,
                recurrence: .daily,
                dueDate: dayStart
            ))
        }

        return newInstances
    }
}
