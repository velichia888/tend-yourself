import Foundation

struct Medication: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dose: String
    /// Hour/minute only (no date/year) — expanded onto a concrete day by
    /// MedicationEngine.todaysDoses.
    var scheduleTimes: [DateComponents]
    var pillsRemaining: Int?
    var refillReminderThreshold: Int?
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        dose: String,
        scheduleTimes: [DateComponents],
        pillsRemaining: Int? = nil,
        refillReminderThreshold: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dose = dose
        self.scheduleTimes = scheduleTimes
        self.pillsRemaining = pillsRemaining
        self.refillReminderThreshold = refillReminderThreshold
        self.notes = notes
    }
}
