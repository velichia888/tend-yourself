import XCTest
@testable import Tend

final class GardenEngineTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ year: Int, _ month: Int, _ dayOfMonth: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = dayOfMonth
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components)!
    }

    func testNoQualifyingDaysIsZeroStreak() {
        let streak = GardenEngine.currentStreak(qualifyingDays: [], today: day(2026, 8, 30), calendar: calendar)
        XCTAssertEqual(streak, 0)
    }

    func testThreeConsecutiveDaysEndingTodayIsStreakOfThree() {
        let days: Set<Date> = [day(2026, 8, 28), day(2026, 8, 29), day(2026, 8, 30)]
        let streak = GardenEngine.currentStreak(qualifyingDays: days, today: day(2026, 8, 30), calendar: calendar)
        XCTAssertEqual(streak, 3)
    }

    func testTodayNotYetQualifiedStillCountsStreakThroughYesterday() {
        // Today (8/30) hasn't bloomed yet, but 8/28-8/29 did — streak
        // should read as 2, not reset to 0, since today isn't over.
        let days: Set<Date> = [day(2026, 8, 28), day(2026, 8, 29)]
        let streak = GardenEngine.currentStreak(qualifyingDays: days, today: day(2026, 8, 30), calendar: calendar)
        XCTAssertEqual(streak, 2)
    }

    func testGapBreaksStreak() {
        // Missed 8/29 entirely -> only today (and today alone) counts.
        let days: Set<Date> = [day(2026, 8, 27), day(2026, 8, 30)]
        let streak = GardenEngine.currentStreak(qualifyingDays: days, today: day(2026, 8, 30), calendar: calendar)
        XCTAssertEqual(streak, 1)
    }

    func testLongestStreakFindsBestRunNotJustCurrentOne() {
        // A 4-day run in the past, then a gap, then a 2-day run ending today.
        let days: Set<Date> = [
            day(2026, 8, 1), day(2026, 8, 2), day(2026, 8, 3), day(2026, 8, 4),
            day(2026, 8, 29), day(2026, 8, 30),
        ]
        XCTAssertEqual(GardenEngine.longestStreak(qualifyingDays: days, calendar: calendar), 4)
    }

    func testEmptySetLongestStreakIsZero() {
        XCTAssertEqual(GardenEngine.longestStreak(qualifyingDays: [], calendar: calendar), 0)
    }
}
