import Foundation

enum MedicationDoseStatus: String, Codable {
    case pending, taken, later, skipped
}

struct MedicationLogEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var medicationID: UUID
    var scheduledFor: Date
    var status: MedicationDoseStatus
    var recordedAt: Date

    init(
        id: UUID = UUID(),
        medicationID: UUID,
        scheduledFor: Date,
        status: MedicationDoseStatus,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.medicationID = medicationID
        self.scheduledFor = scheduledFor
        self.status = status
        self.recordedAt = recordedAt
    }
}
