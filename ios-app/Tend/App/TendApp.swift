import SwiftUI
import UIKit

@main
struct TendApp: App {
    @StateObject private var store = WaterLogStore()

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
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(Theme.accent)
                .task {
                    // No login, no Keychain — unlike every other app this
                    // session, Tend has nothing to wait on beyond the
                    // view actually appearing, so this marker alone is
                    // enough for Codemagic's screenshot step to poll for.
                    #if DEBUG
                    if ProcessInfo.processInfo.environment["IOS_TEST_AUTOMATION"] == "1" {
                        if ProcessInfo.processInfo.environment["IOS_TEST_SEED_DATA"] == "1",
                           store.entries.isEmpty {
                            seedScreenshotData()
                        }
                        print("IOS_TEST_APP_LAUNCHED")
                    }
                    #endif
                }
        }
    }

    #if DEBUG
    /// Screenshot-only fixture data: today partially logged (visible
    /// flower growth) plus two prior qualifying days (non-empty garden
    /// and streak). Never compiled into Release builds.
    private func seedScreenshotData() {
        let calendar = Calendar.current
        let now = Date()
        store.logWater(amountML: 750, at: now)

        for daysAgo in [1, 2] {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            store.logWater(amountML: store.dailyGoalML, at: day)
        }
    }
    #endif
}
