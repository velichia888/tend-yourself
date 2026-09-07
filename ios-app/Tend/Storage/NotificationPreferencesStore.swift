import Foundation

/// Per-category reminder toggles + times, each independently
/// controllable. UserDefaults-only — there's no growing log here, just
/// settings, same exception as MeditationPreferencesStore.
@MainActor
final class NotificationPreferencesStore: ObservableObject {
    private enum Keys {
        static let waterEnabled = "tend.notify.waterEnabled"
        static let waterHour = "tend.notify.waterHour"
        static let waterMinute = "tend.notify.waterMinute"
        static let medicationEnabled = "tend.notify.medicationEnabled"
        static let refillEnabled = "tend.notify.refillEnabled"
        static let tasksEnabled = "tend.notify.tasksEnabled"
        static let meditationEnabled = "tend.notify.meditationEnabled"
        static let meditationHour = "tend.notify.meditationHour"
        static let meditationMinute = "tend.notify.meditationMinute"
        static let dailyCheckInEnabled = "tend.notify.dailyCheckInEnabled"
        static let dailyCheckInHour = "tend.notify.dailyCheckInHour"
        static let dailyCheckInMinute = "tend.notify.dailyCheckInMinute"
        static let privacyModeEnabled = "tend.notify.privacyModeEnabled"
    }

    /// When on, notification bodies avoid naming specific medications or
    /// showing journal content — e.g. a lock-screen preview shouldn't
    /// reveal what someone takes medication for.
    @Published var privacyModeEnabled: Bool { didSet { save(Keys.privacyModeEnabled, privacyModeEnabled) } }

    @Published var waterEnabled: Bool { didSet { save(Keys.waterEnabled, waterEnabled) } }
    @Published var waterHour: Int { didSet { save(Keys.waterHour, waterHour) } }
    @Published var waterMinute: Int { didSet { save(Keys.waterMinute, waterMinute) } }

    @Published var medicationEnabled: Bool { didSet { save(Keys.medicationEnabled, medicationEnabled) } }
    @Published var refillEnabled: Bool { didSet { save(Keys.refillEnabled, refillEnabled) } }
    @Published var tasksEnabled: Bool { didSet { save(Keys.tasksEnabled, tasksEnabled) } }

    @Published var meditationEnabled: Bool { didSet { save(Keys.meditationEnabled, meditationEnabled) } }
    @Published var meditationHour: Int { didSet { save(Keys.meditationHour, meditationHour) } }
    @Published var meditationMinute: Int { didSet { save(Keys.meditationMinute, meditationMinute) } }

    @Published var dailyCheckInEnabled: Bool { didSet { save(Keys.dailyCheckInEnabled, dailyCheckInEnabled) } }
    @Published var dailyCheckInHour: Int { didSet { save(Keys.dailyCheckInHour, dailyCheckInHour) } }
    @Published var dailyCheckInMinute: Int { didSet { save(Keys.dailyCheckInMinute, dailyCheckInMinute) } }

    init() {
        let d = UserDefaults.standard
        waterEnabled = d.object(forKey: Keys.waterEnabled) as? Bool ?? false
        waterHour = d.object(forKey: Keys.waterHour) as? Int ?? 10
        waterMinute = d.object(forKey: Keys.waterMinute) as? Int ?? 0

        medicationEnabled = d.object(forKey: Keys.medicationEnabled) as? Bool ?? true
        refillEnabled = d.object(forKey: Keys.refillEnabled) as? Bool ?? true
        tasksEnabled = d.object(forKey: Keys.tasksEnabled) as? Bool ?? true

        meditationEnabled = d.object(forKey: Keys.meditationEnabled) as? Bool ?? false
        meditationHour = d.object(forKey: Keys.meditationHour) as? Int ?? 9
        meditationMinute = d.object(forKey: Keys.meditationMinute) as? Int ?? 0

        dailyCheckInEnabled = d.object(forKey: Keys.dailyCheckInEnabled) as? Bool ?? false
        dailyCheckInHour = d.object(forKey: Keys.dailyCheckInHour) as? Int ?? 20
        dailyCheckInMinute = d.object(forKey: Keys.dailyCheckInMinute) as? Int ?? 0

        privacyModeEnabled = d.object(forKey: Keys.privacyModeEnabled) as? Bool ?? true
    }

    private func save(_ key: String, _ value: Bool) { UserDefaults.standard.set(value, forKey: key) }
    private func save(_ key: String, _ value: Int) { UserDefaults.standard.set(value, forKey: key) }
}
