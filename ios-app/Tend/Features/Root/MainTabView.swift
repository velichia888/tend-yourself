import SwiftUI

struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Home", systemImage: "drop.fill") }
                .tag(0)

            GardenView()
                .tabItem { Label("Garden", systemImage: "leaf.fill") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(2)
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

#Preview {
    MainTabView().environmentObject(WaterLogStore())
}
