import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "drop.fill") }

            GardenView()
                .tabItem { Label("Garden", systemImage: "leaf.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    MainTabView().environmentObject(WaterLogStore())
}
