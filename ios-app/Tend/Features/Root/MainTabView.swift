import SwiftUI

struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MeditateView()
                .tabItem { Label("Meditate", systemImage: "wind") }
                .tag(1)

            TasksView()
                .tabItem { Label("Tasks", systemImage: "checkmark.circle.fill") }
                .tag(2)

            JournalGateView()
                .tabItem { Label("Journal", systemImage: "book.fill") }
                .tag(3)

            YouView()
                .tabItem { Label("You", systemImage: "person.fill") }
                .tag(4)
        }
        .onAppear {
            // CI screenshot automation only — see codemagic.yaml's
            // "Launch app in cloud simulator" step, which launches once
            // per tab to capture each screen without needing real UI
            // taps on the simulator.
            #if DEBUG
            if let raw = ProcessInfo.processInfo.environment["IOS_TEST_INITIAL_TAB"],
               let tab = Int(raw) {
                selection = tab
            }
            #endif
        }
    }
}
