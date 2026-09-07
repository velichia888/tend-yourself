import Foundation
import Combine

/// Observes the stores that drive reminders and keeps scheduled
/// notifications in sync with them + NotificationPreferencesStore's
/// toggles. Kept separate from the stores themselves so each store
/// stays a plain data model, not a notification-scheduling concern.
@MainActor
final class NotificationCoordinator: ObservableObject {
    private static let waterID = "tend.water.daily"
    private static let meditationID = "tend.meditation.daily"
    private static let dailyCheckInID = "tend.dailyCheckIn"
    private static let taskPrefix = "tend.task."
    private static let medicationPrefix = "tend.medication."
    private static let refillPrefix = "tend.refill."

    private let scheduler: NotificationScheduling
    private let preferences: NotificationPreferencesStore
    private let taskStore: TaskStore
    private let medicationStore: MedicationStore

    private var cancellables: Set<AnyCancellable> = []
    private var lastKnownPillsRemaining: [UUID: Int] = [:]

    init(
        scheduler: NotificationScheduling,
        preferences: NotificationPreferencesStore,
        taskStore: TaskStore,
        medicationStore: MedicationStore
    ) {
        self.scheduler = scheduler
        self.preferences = preferences
        self.taskStore = taskStore
        self.medicationStore = medicationStore

        lastKnownPillsRemaining = Dictionary(
            uniqueKeysWithValues: medicationStore.medications.compactMap { med in
                med.pillsRemaining.map { (med.id, $0) }
            }
        )

        observe()
    }

    func requestAuthorizationIfNeeded() {
        Task {
            _ = await scheduler.requestAuthorization()
            syncAll()
        }
    }

    func syncAll() {
        syncWater()
        syncMeditation()
        syncDailyCheckIn()
        syncTasks()
        syncMedications()
    }

    private func observe() {
        preferences.objectWillChange
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.syncAll() }
            .store(in: &cancellables)

        taskStore.$tasks
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.syncTasks() }
            .store(in: &cancellables)

        medicationStore.$medications
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] medications in self?.syncMedications(medications) }
            .store(in: &cancellables)
    }

    private func syncWater() {
        scheduler.cancel(id: Self.waterID)
        guard preferences.waterEnabled else { return }
        scheduler.scheduleDaily(
            id: Self.waterID,
            title: "Time to hydrate",
            body: "A glass of water is a small step toward today's goal.",
            hour: preferences.waterHour,
            minute: preferences.waterMinute
        )
    }

    private func syncMeditation() {
        scheduler.cancel(id: Self.meditationID)
        guard preferences.meditationEnabled else { return }
        scheduler.scheduleDaily(
            id: Self.meditationID,
            title: "A calmer moment",
            body: "A few mindful breaths can change your whole day.",
            hour: preferences.meditationHour,
            minute: preferences.meditationMinute
        )
    }

    private func syncDailyCheckIn() {
        scheduler.cancel(id: Self.dailyCheckInID)
        guard preferences.dailyCheckInEnabled else { return }
        scheduler.scheduleDaily(
            id: Self.dailyCheckInID,
            title: "How are you feeling today?",
            body: "Take a moment for yourself in Journal.",
            hour: preferences.dailyCheckInHour,
            minute: preferences.dailyCheckInMinute
        )
    }

    private func syncTasks() {
        scheduler.cancel(idsWithPrefix: Self.taskPrefix)
        guard preferences.tasksEnabled else { return }
        for task in taskStore.todayTasks {
            guard let reminder = task.reminderTime, let hour = reminder.hour, let minute = reminder.minute else { continue }
            let title = preferences.privacyModeEnabled ? "Tend reminder" : task.title
            let body = preferences.privacyModeEnabled ? "You have a task waiting in Tend." : (task.subtitle ?? "A small step for today.")
            scheduler.scheduleDaily(
                id: "\(Self.taskPrefix)\(task.id.uuidString)",
                title: title,
                body: body,
                hour: hour,
                minute: minute
            )
        }
    }

    private func syncMedications(_ medications: [Medication]? = nil) {
        let medications = medications ?? medicationStore.medications
        scheduler.cancel(idsWithPrefix: Self.medicationPrefix)

        if preferences.medicationEnabled {
            for medication in medications {
                for time in medication.scheduleTimes {
                    guard let hour = time.hour, let minute = time.minute else { continue }
                    let title = preferences.privacyModeEnabled ? "Tend reminder" : medication.name
                    let body = preferences.privacyModeEnabled ? "You have a scheduled item in Medication." : "\(medication.dose) — \(MedicationCopy.disclosure)"
                    scheduler.scheduleDaily(
                        id: "\(Self.medicationPrefix)\(medication.id.uuidString)-\(hour)-\(minute)",
                        title: title,
                        body: body,
                        hour: hour,
                        minute: minute
                    )
                }
            }
        }

        checkForNewlyLowRefills(medications)
    }

    /// Refill reminders are event-driven, not scheduled: fire a one-shot
    /// notification the moment a medication's remaining count first
    /// crosses at/below its threshold, rather than repeating on a timer.
    private func checkForNewlyLowRefills(_ medications: [Medication]) {
        for medication in medications {
            defer { lastKnownPillsRemaining[medication.id] = medication.pillsRemaining }

            guard preferences.refillEnabled, MedicationEngine.needsRefill(medication) else { continue }
            let previous = lastKnownPillsRemaining[medication.id]
            let justCrossedThreshold = previous == nil || (medication.pillsRemaining ?? 0) < (previous ?? Int.max)
            guard justCrossedThreshold else { continue }

            let body = preferences.privacyModeEnabled ? "Something in Medication needs your attention." : "\(medication.name) is running low."
            scheduler.scheduleOneShot(
                id: "\(Self.refillPrefix)\(medication.id.uuidString)-\(UUID().uuidString)",
                title: "Refill reminder",
                body: body,
                secondsFromNow: 2
            )
        }
    }
}
