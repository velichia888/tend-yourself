import SwiftUI

/// CI screenshot automation only — screens that are no longer tabs
/// (Water/Garden, Medication, Resources, Hard Day Mode) still need a
/// way to be reached without real UI taps, since there's no
/// XCUITest/idb set up. See codemagic.yaml's capture_deep_screen().
#if DEBUG
private enum CIDeepScreen: String {
    case medication, resources, water, garden, hardDayMode
}
#endif

struct RootView: View {
    #if DEBUG
    @State private var deepScreen: CIDeepScreen?
    #endif

    var body: some View {
        MainTabView()
            #if DEBUG
            .fullScreenCover(item: deepScreenBinding) { item in
                NavigationStack {
                    deepScreenDestination(for: item.screen)
                }
            }
            .onAppear {
                if let raw = ProcessInfo.processInfo.environment["IOS_TEST_DEEP_SCREEN"] {
                    deepScreen = CIDeepScreen(rawValue: raw)
                }
            }
            #endif
    }

    #if DEBUG
    private var deepScreenBinding: Binding<CIDeepScreenItem?> {
        Binding(
            get: { deepScreen.map(CIDeepScreenItem.init) },
            set: { deepScreen = $0?.screen }
        )
    }

    @ViewBuilder
    private func deepScreenDestination(for screen: CIDeepScreen) -> some View {
        switch screen {
        case .medication: MedicationView()
        case .resources: ResourcesView()
        case .water: WaterView()
        case .garden: GardenView()
        case .hardDayMode: HardDayModeView()
        }
    }
    #endif
}

#if DEBUG
/// `.fullScreenCover(item:)` needs an Identifiable, which a plain enum
/// with a String rawValue doesn't give us "for free" through
/// Binding<CIDeepScreen?> alone — this thin wrapper supplies that.
private struct CIDeepScreenItem: Identifiable {
    let screen: CIDeepScreen
    var id: String { screen.rawValue }
}
#endif
