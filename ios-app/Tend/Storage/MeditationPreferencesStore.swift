import Foundation

/// Deliberate exception to the JSON-file store pattern: there's no
/// growing log to persist for Meditation, only two small preferences,
/// so UserDefaults alone is enough.
@MainActor
final class MeditationPreferencesStore: ObservableObject {
    private enum Keys {
        static let lastUsedDurationMin = "tend.meditation.lastUsedDurationMin"
        static let favoriteSessionIDs = "tend.meditation.favoriteSessionIDs"
    }

    @Published var lastUsedDurationMin: Int {
        didSet { UserDefaults.standard.set(lastUsedDurationMin, forKey: Keys.lastUsedDurationMin) }
    }

    @Published var favoriteSessionIDs: Set<String> {
        didSet { UserDefaults.standard.set(Array(favoriteSessionIDs), forKey: Keys.favoriteSessionIDs) }
    }

    init() {
        let storedDuration = UserDefaults.standard.object(forKey: Keys.lastUsedDurationMin) as? Int
        self.lastUsedDurationMin = storedDuration ?? 3

        let storedFavorites = UserDefaults.standard.array(forKey: Keys.favoriteSessionIDs) as? [String] ?? []
        self.favoriteSessionIDs = Set(storedFavorites)
    }

    func toggleFavorite(_ sessionID: String) {
        if favoriteSessionIDs.contains(sessionID) {
            favoriteSessionIDs.remove(sessionID)
        } else {
            favoriteSessionIDs.insert(sessionID)
        }
    }
}
