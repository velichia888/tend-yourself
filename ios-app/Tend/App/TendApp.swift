import SwiftUI
import UIKit

@main
struct TendApp: App {
    @StateObject private var waterStore = WaterLogStore()
    // taskStore/medicationStore/notificationPreferences have no inline
    // default: they're constructed once in init() below and shared with
    // notificationCoordinator, which needs references to them at
    // construction time. Giving them an inline default here as well
    // would construct a second, throwaway instance of each — harmless
    // for notificationPreferences, but a real bug for taskStore, whose
    // init() has a disk-write side effect (rollForwardIfNeeded).
    @StateObject private var taskStore: TaskStore
    @StateObject private var medicationStore: MedicationStore
    @StateObject private var journalStore = JournalStore()
    @StateObject private var meditationPreferences = MeditationPreferencesStore()
    @StateObject private var supportPlanStore = SupportPlanStore()
    @StateObject private var notificationPreferences: NotificationPreferencesStore
    @StateObject private var notificationCoordinator: NotificationCoordinator

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.canvas)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.ink)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Theme.ink)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Theme.surface)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Coordinator is built here (not as a plain default-init
        // @StateObject) since it needs references to the other stores
        // at construction time.
        let preferences = NotificationPreferencesStore()
        let tasks = TaskStore()
        let medications = MedicationStore()
        _notificationPreferences = StateObject(wrappedValue: preferences)
        _taskStore = StateObject(wrappedValue: tasks)
        _medicationStore = StateObject(wrappedValue: medications)
        _notificationCoordinator = StateObject(wrappedValue: NotificationCoordinator(
            scheduler: NotificationService(),
            preferences: preferences,
            taskStore: tasks,
            medicationStore: medications
        ))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(waterStore)
                .environmentObject(taskStore)
                .environmentObject(medicationStore)
                .environmentObject(journalStore)
                .environmentObject(meditationPreferences)
                .environmentObject(supportPlanStore)
                .environmentObject(notificationPreferences)
                .environmentObject(notificationCoordinator)
                .tint(Theme.accent)
                .task {
                    // No login, no Keychain — unlike every other app this
                    // session, Tend has nothing to wait on beyond the
                    // view actually appearing, so this marker alone is
                    // enough for Codemagic's screenshot step to poll for.
                    #if DEBUG
                    if ProcessInfo.processInfo.environment["IOS_TEST_AUTOMATION"] == "1" {
                        if ProcessInfo.processInfo.environment["IOS_TEST_SEED_DATA"] == "1",
                           waterStore.entries.isEmpty {
                            seedScreenshotData()
                        }
                        print("IOS_TEST_APP_LAUNCHED")
                    }
                    #endif
                }
        }
    }

    #if DEBUG
    /// Screenshot-only fixture data across every store, guarded per
    /// store so relaunching for a later tab/deep-screen during the same
    /// CI run never double-seeds. Never compiled into Release builds.
    private func seedScreenshotData() {
        let calendar = Calendar.current
        let now = Date()

        waterStore.logWater(amountML: 750, at: now)
        for daysAgo in [1, 2] {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            waterStore.logWater(amountML: waterStore.dailyGoalML, at: day)
        }

        if taskStore.tasks.isEmpty {
            taskStore.addTask(title: "Morning stretch", timeBlock: .morning, priority: .niceToDo)
            taskStore.addTask(title: "Drink water", subtitle: "Nourish your body", timeBlock: .morning, priority: .mustDo, recurrence: .daily)
            taskStore.addTask(title: "Healthy lunch", timeBlock: .afternoon, priority: .mustDo)
            taskStore.addTask(title: "Journal before bed", timeBlock: .evening, priority: .niceToDo)
        }

        if medicationStore.medications.isEmpty {
            medicationStore.addMedication(Medication(
                name: "Sertraline",
                dose: "50 mg",
                scheduleTimes: [DateComponents(hour: 8, minute: 0)],
                pillsRemaining: 5,
                refillReminderThreshold: 5
            ))
        }

        if journalStore.entries.isEmpty {
            journalStore.addEntry(JournalEntry(mood: .good, gratitudeNote: "A quiet morning."))
        }
    }
    #endif
}
