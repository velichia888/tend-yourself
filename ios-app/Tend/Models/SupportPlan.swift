import Foundation

/// A singleton struct, not an array-of-entries — there's only ever one
/// support plan per user, unlike the log-style domains elsewhere.
struct SupportPlan: Codable, Equatable {
    var savedTechniqueIDs: [String]
    var safePlaces: [String]
    var contacts: [SupportContact]

    init(savedTechniqueIDs: [String] = [], safePlaces: [String] = [], contacts: [SupportContact] = []) {
        self.savedTechniqueIDs = savedTechniqueIDs
        self.safePlaces = safePlaces
        self.contacts = contacts
    }
}
