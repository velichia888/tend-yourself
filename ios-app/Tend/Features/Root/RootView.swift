import SwiftUI

/// No auth, no loading/session state — see docs/MVP_SCOPE.md. RootView
/// exists as a thin wrapper so App/TendApp.swift has a single, stable
/// place to attach the CI-readiness marker regardless of what Root ends
/// up containing later.
struct RootView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    RootView().environmentObject(WaterLogStore())
}
