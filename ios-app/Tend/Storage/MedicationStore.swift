import Foundation

/// Non-diagnostic disclosure, shown wherever medication status is
/// displayed: Tend only records what the user tells it. It never
/// infers, suggests, or second-guesses a dose.
enum MedicationCopy {
    static let disclosure = "Tend tracks what you enter. It won't tell you to change your dose or stop a medication."
}

/// Local-only persistence, mirroring WaterLogStore/TaskStore: two plain
/// JSON files in Documents (medications + their dose log), no backend.
@MainActor
final class MedicationStore: ObservableObject {
    @Published private(set) var medications: [Medication] = []
    @Published private(set) var log: [MedicationLogEntry] = []

    private let medicationsFileURL: URL
    private let logFileURL: URL
    private let calendar: Calendar

    init(medicationsFileURL: URL? = nil, logFileURL: URL? = nil, calendar: Calendar = .current) {
        self.calendar = calendar
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.medicationsFileURL = medicationsFileURL ?? documents.appendingPathComponent("tend_medications.json")
        self.logFileURL = logFileURL ?? documents.appendingPathComponent("tend_medication_log.json")
        load()
    }

    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveMedications()
    }

    func updatePillsRemaining(_ medication: Medication, to count: Int) {
        guard let index = medications.firstIndex(where: { $0.id == medication.id }) else { return }
        medications[index].pillsRemaining = count
        saveMedications()
    }

    func recordDose(_ dose: MedicationEngine.Dose, status: MedicationDoseStatus) {
        if let index = log.firstIndex(where: {
            $0.medicationID == dose.medication.id && $0.scheduledFor == dose.scheduledFor
        }) {
            log[index].status = status
            log[index].recordedAt = Date()
        } else {
            log.append(MedicationLogEntry(medicationID: dose.medication.id, scheduledFor: dose.scheduledFor, status: status))
        }
        saveLog()
    }

    func resetAllData() {
        medications = []
        log = []
        saveMedications()
        saveLog()
    }

    var todaysDoses: [MedicationEngine.Dose] {
        MedicationEngine.todaysDoses(medications: medications, for: Date(), calendar: calendar)
    }

    func status(for dose: MedicationEngine.Dose) -> MedicationDoseStatus {
        MedicationEngine.status(for: dose, in: log)
    }

    var todaysCompletedCount: (completed: Int, total: Int) {
        MedicationEngine.completedCount(doses: todaysDoses, log: log)
    }

    var medicationsNeedingRefill: [Medication] {
        medications.filter(MedicationEngine.needsRefill)
    }

    private func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let data = try? Data(contentsOf: medicationsFileURL),
           let decoded = try? decoder.decode([Medication].self, from: data) {
            medications = decoded
        }
        if let data = try? Data(contentsOf: logFileURL),
           let decoded = try? decoder.decode([MedicationLogEntry].self, from: data) {
            log = decoded
        }
    }

    private func saveMedications() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(medications) else { return }
        try? data.write(to: medicationsFileURL, options: .atomic)
    }

    private func saveLog() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(log) else { return }
        try? data.write(to: logFileURL, options: .atomic)
    }
}
