import Foundation

enum Mood: Int, Codable, CaseIterable {
    case terrible = 0, down, okay, good, great

    var label: String {
        switch self {
        case .terrible: return "Terrible"
        case .down: return "Down"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }
}

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var mood: Mood?
    var needsTags: [String]
    var freeformText: String
    var gratitudeNote: String
    /// 0...1 sliders, matching the mockups' Low/Medium/High and
    /// Poor/Okay/Great labeled ranges.
    var energyLevel: Double
    var sleepQuality: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood? = nil,
        needsTags: [String] = [],
        freeformText: String = "",
        gratitudeNote: String = "",
        energyLevel: Double = 0.5,
        sleepQuality: Double = 0.5
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.needsTags = needsTags
        self.freeformText = freeformText
        self.gratitudeNote = gratitudeNote
        self.energyLevel = energyLevel
        self.sleepQuality = sleepQuality
    }
}
