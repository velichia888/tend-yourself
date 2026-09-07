import XCTest
@testable import Tend

final class TaskEngineTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ year: Int, _ month: Int, _ dayOfMonth: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = dayOfMonth
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components)!
    }

    private func task(
        templateID: UUID? = nil,
        title: String = "Task",
        timeBlock: TaskItem.TimeBlock = .morning,
        priority: TaskItem.Priority = .mustDo,
        recurrence: TaskItem.Recurrence = .none,
        dueDate: Date,
        completed: Bool = false
    ) -> TaskItem {
        TaskItem(
            templateID: templateID,
            title: title,
            timeBlock: timeBlock,
            priority: priority,
            recurrence: recurrence,
            dueDate: dueDate,
            completedAt: completed ? dueDate : nil
        )
    }

    func testTasksDueFiltersToExactCalendarDay() {
        let today = day(2026, 9, 6)
        let tasks = [
            task(dueDate: today),
            task(dueDate: day(2026, 9, 5)),
        ]
        XCTAssertEqual(TaskEngine.tasks(due: today, in: tasks, calendar: calendar).count, 1)
    }

    func testGroupingByTimeBlock() {
        let today = day(2026, 9, 6)
        let tasks = [
            task(timeBlock: .morning, dueDate: today),
            task(timeBlock: .morning, dueDate: today),
            task(timeBlock: .evening, dueDate: today),
        ]
        let grouped = TaskEngine.grouping(tasks)
        XCTAssertEqual(grouped[.morning]?.count, 2)
        XCTAssertEqual(grouped[.evening]?.count, 1)
        XCTAssertNil(grouped[.afternoon])
    }

    func testProgressIsZeroForEmptyList() {
        XCTAssertEqual(TaskEngine.progress(for: []), 0)
    }

    func testProgressIsFractionComplete() {
        let today = day(2026, 9, 6)
        let tasks = [
            task(dueDate: today, completed: true),
            task(dueDate: today, completed: true),
            task(dueDate: today, completed: false),
            task(dueDate: today, completed: false),
        ]
        XCTAssertEqual(TaskEngine.progress(for: tasks), 0.5)
    }

    func testRollForwardCreatesTodaysInstanceWhenMissing() {
        let templateID = UUID()
        let yesterday = day(2026, 9, 5)
        let today = day(2026, 9, 6)
        let existing = [task(templateID: templateID, title: "Stretch", recurrence: .daily, dueDate: yesterday)]

        let newInstances = TaskEngine.rollForward(allTasks: existing, to: today, calendar: calendar)

        XCTAssertEqual(newInstances.count, 1)
        XCTAssertEqual(newInstances.first?.title, "Stretch")
        XCTAssertTrue(calendar.isDate(newInstances.first!.dueDate, inSameDayAs: today))
    }

    func testRollForwardDoesNotDuplicateWhenTodayAlreadyExists() {
        let templateID = UUID()
        let today = day(2026, 9, 6)
        let existing = [task(templateID: templateID, recurrence: .daily, dueDate: today)]

        XCTAssertTrue(TaskEngine.rollForward(allTasks: existing, to: today, calendar: calendar).isEmpty)
    }

    func testRollForwardNeverBackfillsPastMissedDays() {
        // Template's last instance is from 5 days ago; rolling forward
        // to "today" must only ever produce a single new instance dated
        // today — never one for each missed day in between.
        let templateID = UUID()
        let fiveDaysAgo = day(2026, 9, 1)
        let today = day(2026, 9, 6)
        let existing = [task(templateID: templateID, recurrence: .daily, dueDate: fiveDaysAgo)]

        let newInstances = TaskEngine.rollForward(allTasks: existing, to: today, calendar: calendar)

        XCTAssertEqual(newInstances.count, 1)
        XCTAssertTrue(calendar.isDate(newInstances.first!.dueDate, inSameDayAs: today))
    }

    func testRollForwardIgnoresOneOffTasks() {
        let today = day(2026, 9, 6)
        let existing = [task(recurrence: .none, dueDate: day(2026, 9, 1))]
        XCTAssertTrue(TaskEngine.rollForward(allTasks: existing, to: today, calendar: calendar).isEmpty)
    }
}
