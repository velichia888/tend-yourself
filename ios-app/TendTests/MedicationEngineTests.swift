import XCTest
@testable import Tend

final class MedicationEngineTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ year: Int, _ month: Int, _ dayOfMonth: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = dayOfMonth
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components)!
    }

    private func medication(
        name: String = "Sertraline",
        scheduleTimes: [DateComponents],
        pillsRemaining: Int? = nil,
        refillReminderThreshold: Int? = nil
    ) -> Medication {
        Medication(name: name, dose: "50 mg", scheduleTimes: scheduleTimes, pillsRemaining: pillsRemaining, refillReminderThreshold: refillReminderThreshold)
    }

    func testTodaysDosesExpandsScheduleTimesOntoConcreteDay() {
        let today = day(2026, 9, 6)
        let med = medication(scheduleTimes: [DateComponents(hour: 8, minute: 0), DateComponents(hour: 20, minute: 0)])

        let doses = MedicationEngine.todaysDoses(medications: [med], for: today, calendar: calendar)

        XCTAssertEqual(doses.count, 2)
        XCTAssertTrue(doses.allSatisfy { calendar.isDate($0.scheduledFor, inSameDayAs: today) })
    }

    func testTodaysDosesAreSortedByTime() {
        let today = day(2026, 9, 6)
        let med = medication(scheduleTimes: [DateComponents(hour: 20, minute: 0), DateComponents(hour: 8, minute: 0)])

        let doses = MedicationEngine.todaysDoses(medications: [med], for: today, calendar: calendar)

        XCTAssertEqual(calendar.component(.hour, from: doses[0].scheduledFor), 8)
        XCTAssertEqual(calendar.component(.hour, from: doses[1].scheduledFor), 20)
    }

    func testStatusDefaultsToPendingWithNoLogEntry() {
        let today = day(2026, 9, 6)
        let med = medication(scheduleTimes: [DateComponents(hour: 8, minute: 0)])
        let dose = MedicationEngine.todaysDoses(medications: [med], for: today, calendar: calendar)[0]

        XCTAssertEqual(MedicationEngine.status(for: dose, in: []), .pending)
    }

    func testStatusReflectsMatchingLogEntry() {
        let today = day(2026, 9, 6)
        let med = medication(scheduleTimes: [DateComponents(hour: 8, minute: 0)])
        let dose = MedicationEngine.todaysDoses(medications: [med], for: today, calendar: calendar)[0]
        let entry = MedicationLogEntry(medicationID: med.id, scheduledFor: dose.scheduledFor, status: .taken)

        XCTAssertEqual(MedicationEngine.status(for: dose, in: [entry]), .taken)
    }

    func testCompletedCountOnlyCountsTakenDoses() {
        let today = day(2026, 9, 6)
        let med = medication(scheduleTimes: [DateComponents(hour: 8, minute: 0), DateComponents(hour: 20, minute: 0)])
        let doses = MedicationEngine.todaysDoses(medications: [med], for: today, calendar: calendar)
        let log = [
            MedicationLogEntry(medicationID: med.id, scheduledFor: doses[0].scheduledFor, status: .taken),
            MedicationLogEntry(medicationID: med.id, scheduledFor: doses[1].scheduledFor, status: .skipped),
        ]

        let result = MedicationEngine.completedCount(doses: doses, log: log)
        XCTAssertEqual(result.completed, 1)
        XCTAssertEqual(result.total, 2)
    }

    func testNeedsRefillTrueWhenAtOrBelowThreshold() {
        let med = medication(scheduleTimes: [], pillsRemaining: 5, refillReminderThreshold: 5)
        XCTAssertTrue(MedicationEngine.needsRefill(med))
    }

    func testNeedsRefillFalseWhenAboveThreshold() {
        let med = medication(scheduleTimes: [], pillsRemaining: 10, refillReminderThreshold: 5)
        XCTAssertFalse(MedicationEngine.needsRefill(med))
    }

    func testNeedsRefillFalseWhenNoRefillTrackingSet() {
        let med = medication(scheduleTimes: [])
        XCTAssertFalse(MedicationEngine.needsRefill(med))
    }
}
