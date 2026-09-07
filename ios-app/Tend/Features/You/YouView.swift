import SwiftUI

struct YouView: View {
    @EnvironmentObject private var waterStore: WaterLogStore
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var medicationStore: MedicationStore
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var supportPlanStore: SupportPlanStore

    @State private var goalText = ""
    @State private var showingResetConfirmation = false
    @State private var resetAuthFailed = false
    @FocusState private var goalFieldFocused: Bool

    private let authService: BiometricAuthenticating

    init(authService: BiometricAuthenticating = BiometricAuthService()) {
        self.authService = authService
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Water") {
                    HStack {
                        Text("Daily Goal")
                        Spacer()
                        TextField("ml", text: $goalText)
                            .keyboardType(.numberPad)
                            .focused($goalFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("ml").foregroundStyle(Theme.inkSoft)
                    }
                }

                Section {
                    Toggle("Require Face ID for Journal", isOn: $journalStore.lockEnabled)
                } footer: {
                    Text("When on, your journal entries are hidden behind Face ID, Touch ID, or your device passcode.")
                }

                Section {
                    NavigationLink("Notifications") {
                        NotificationSettingsView()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Text("Clear All Data")
                    }
                } footer: {
                    Text("Deletes everything Tend has stored on this device — water log, tasks, medications, journal entries, and your support plan. This cannot be undone, so it requires Face ID or your passcode first.")
                }
            }
            .navigationTitle("You")
            .onAppear { goalText = "\(waterStore.dailyGoalML)" }
            .onChange(of: goalFieldFocused) { isFocused in
                guard !isFocused else { return }
                commitGoal()
            }
            .confirmationDialog(
                "Clear all data on this device?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) { requestResetAuthorization() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Couldn't verify it's you", isPresented: $resetAuthFailed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Data wasn't cleared. Try again from Settings.")
            }
        }
    }

    private func commitGoal() {
        guard let value = Int(goalText), value > 0 else {
            goalText = "\(waterStore.dailyGoalML)"
            return
        }
        waterStore.dailyGoalML = value
    }

    private func requestResetAuthorization() {
        Task {
            let result = await authService.authenticate(reason: "Confirm it's you before clearing all data")
            switch result {
            case .success, .unavailable:
                resetAllStores()
            case .failure:
                resetAuthFailed = true
            }
        }
    }

    private func resetAllStores() {
        waterStore.resetAllData()
        taskStore.resetAllData()
        medicationStore.resetAllData()
        journalStore.resetAllData()
        supportPlanStore.resetAllData()
    }
}

#Preview {
    YouView()
        .environmentObject(WaterLogStore())
        .environmentObject(TaskStore())
        .environmentObject(MedicationStore())
        .environmentObject(JournalStore())
        .environmentObject(SupportPlanStore())
}
