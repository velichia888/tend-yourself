import Foundation

/// Local-only persistence, mirroring WaterLogStore. No separate Engine
/// file — journal logic is just date filtering, not an algorithm worth
/// isolating the way growth/streak/task-recurrence math is.
@MainActor
final class JournalStore: ObservableObject {
    private enum Keys {
        static let lockEnabled = "tend.journalLockEnabled"
    }

    @Published private(set) var entries: [JournalEntry] = []
    @Published var lockEnabled: Bool {
        didSet { UserDefaults.standard.set(lockEnabled, forKey: Keys.lockEnabled) }
    }

    private let fileURL: URL
    private let calendar: Calendar

    init(fileURL: URL? = nil, calendar: Calendar = .current) {
        self.calendar = calendar
        self.lockEnabled = UserDefaults.standard.object(forKey: Keys.lockEnabled) as? Bool ?? true

        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documents.appendingPathComponent("tend_journal.json")
        }
        load()
    }

    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        save()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func resetAllData() {
        entries = []
        save()
    }

    func entry(for day: Date) -> JournalEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    var entriesThisWeek: [JournalEntry] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return entries.filter { interval.contains($0.date) }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
