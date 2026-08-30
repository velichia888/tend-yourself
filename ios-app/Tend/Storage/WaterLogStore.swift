import Foundation

/// Local-only persistence — see docs/MVP_SCOPE.md for why Tend has no
/// backend. Entries are stored as a plain JSON array in the app's
/// Documents directory; the daily goal lives in UserDefaults.
@MainActor
final class WaterLogStore: ObservableObject {
    private enum Keys {
        static let dailyGoalML = "tend.dailyGoalML"
    }

    static let defaultGoalML = 2000

    @Published private(set) var entries: [WaterLogEntry] = []
    @Published var dailyGoalML: Int {
        didSet { UserDefaults.standard.set(dailyGoalML, forKey: Keys.dailyGoalML) }
    }

    private let fileURL: URL
    private let calendar: Calendar

    init(fileURL: URL? = nil, calendar: Calendar = .current) {
        let storedGoal = UserDefaults.standard.object(forKey: Keys.dailyGoalML) as? Int
        self.dailyGoalML = storedGoal ?? Self.defaultGoalML
        self.calendar = calendar

        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documents.appendingPathComponent("tend_water_log.json")
        }

        load()
    }

    func logWater(amountML: Int, at date: Date = Date()) {
        guard amountML > 0 else { return }
        entries.append(WaterLogEntry(amountML: amountML, loggedAt: date))
        save()
    }

    func deleteEntry(_ entry: WaterLogEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func resetAllData() {
        entries = []
        save()
    }

    func totalML(on day: Date) -> Int {
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return entries
            .filter { $0.loggedAt >= start && $0.loggedAt < end }
            .reduce(0) { $0 + $1.amountML }
    }

    var todayTotalML: Int { totalML(on: Date()) }

    var todayPercent: Double {
        GrowthEngine.percentOfGoal(loggedML: todayTotalML, goalML: dailyGoalML)
    }

    var todayStage: GrowthStage {
        GrowthEngine.stage(forPercent: todayPercent)
    }

    /// Distinct calendar days (normalized to local midnight) whose real
    /// logged total reached Full Bloom.
    var qualifyingDays: Set<Date> {
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.loggedAt) }
        var result: Set<Date> = []
        for (day, dayEntries) in grouped {
            let total = dayEntries.reduce(0) { $0 + $1.amountML }
            if GrowthEngine.dayQualifies(loggedML: total, goalML: dailyGoalML) {
                result.insert(day)
            }
        }
        return result
    }

    var currentStreak: Int {
        GardenEngine.currentStreak(qualifyingDays: qualifyingDays, today: Date(), calendar: calendar)
    }

    var longestStreak: Int {
        GardenEngine.longestStreak(qualifyingDays: qualifyingDays, calendar: calendar)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([WaterLogEntry].self, from: data) {
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
