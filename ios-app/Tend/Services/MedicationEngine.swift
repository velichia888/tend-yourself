import Foundation

/// Pure, deterministic medication-schedule logic, independent of
/// MedicationStore/SwiftUI, same precedent as GrowthEngine/TaskEngine.
enum MedicationEngine {
    struct Dose: Identifiable, Equatable {
        var id: String { "\(medication.id)-\(scheduledFor.timeIntervalSince1970)" }
        let medication: Medication
        let scheduledFor: Date
    }

    /// Expands every medication's `scheduleTimes` onto concrete instants
    /// for `day`.
    static func todaysDoses(medications: [Medication], for day: Date, calendar: Calendar = .current) -> [Dose] {
        let dayStart = calendar.startOfDay(for: day)
        var doses: [Dose] = []

        for medication in medications {
            for time in medication.scheduleTimes {
                var components = calendar.dateComponents([.year, .month, .day], from: dayStart)
                components.hour = time.hour
                components.minute = time.minute
                guard let scheduledFor = calendar.date(from: components) else { continue }
                doses.append(Dose(medication: medication, scheduledFor: scheduledFor))
            }
        }

        return doses.sorted { $0.scheduledFor < $1.scheduledFor }
    }

    static func status(for dose: Dose, in log: [MedicationLogEntry]) -> MedicationDoseStatus {
        log.first {
            $0.medicationID == dose.medication.id && $0.scheduledFor == dose.scheduledFor
        }?.status ?? .pending
    }

    static func completedCount(doses: [Dose], log: [MedicationLogEntry]) -> (completed: Int, total: Int) {
        let completed = doses.filter { status(for: $0, in: log) == .taken }.count
        return (completed, doses.count)
    }

    static func needsRefill(_ medication: Medication) -> Bool {
        guard let remaining = medication.pillsRemaining, let threshold = medication.refillReminderThreshold else {
            return false
        }
        return remaining <= threshold
    }
}
