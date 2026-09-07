import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: WaterLogStore
    @State private var goalText = ""
    @State private var showingResetConfirmation = false
    @FocusState private var goalFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Daily Goal")
                        Spacer()
                        TextField("ml", text: $goalText)
                            .keyboardType(.numberPad)
                            .focused($goalFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("ml")
                            .foregroundStyle(Theme.inkSoft)
                    }
                } header: {
                    Text("Goal")
                } footer: {
                    Text("Changing your goal affects how today (and any past day, when recomputed) is evaluated.")
                }

                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Text("Clear All Data")
                    }
                } footer: {
                    Text("Deletes every logged water entry on this device. This cannot be undone.")
                }
            }
            .navigationTitle("Settings")
            .onAppear { goalText = "\(store.dailyGoalML)" }
            .onChange(of: goalFieldFocused) { isFocused in
                guard !isFocused else { return }
                commitGoal()
            }
            .confirmationDialog(
                "Clear all logged water data?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    store.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func commitGoal() {
        guard let value = Int(goalText), value > 0 else {
            goalText = "\(store.dailyGoalML)"
            return
        }
        store.dailyGoalML = value
    }
}

#Preview {
    SettingsView().environmentObject(WaterLogStore())
}
