import Foundation

struct WaterLogEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var amountML: Int
    var loggedAt: Date

    init(id: UUID = UUID(), amountML: Int, loggedAt: Date = Date()) {
        self.id = id
        self.amountML = amountML
        self.loggedAt = loggedAt
    }
}
