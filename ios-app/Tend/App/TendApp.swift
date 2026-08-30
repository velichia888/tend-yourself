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
                        print("IOS_TEST_APP_LAUNCHED")
                    }
                    #endif
                }
        }
    }
}
