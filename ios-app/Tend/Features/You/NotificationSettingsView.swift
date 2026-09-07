import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject private var preferences: NotificationPreferencesStore
    @EnvironmentObject private var coordinator: NotificationCoordinator

    var body: some View {
        Form {
            Section {
                Toggle("Water reminders", isOn: $preferences.waterEnabled)
                if preferences.waterEnabled {
                    timePicker(hour: $preferences.waterHour, minute: $preferences.waterMinute)
                }
            }

            Section {
                Toggle("Medication reminders", isOn: $preferences.medicationEnabled)
                Toggle("Refill reminders", isOn: $preferences.refillEnabled)
            } footer: {
                Text(MedicationCopy.disclosure)
            }

            Section {
                Toggle("Task reminders", isOn: $preferences.tasksEnabled)
            } footer: {
                Text("Only tasks you've given a reminder time will notify you.")
            }

            Section {
                Toggle("Meditation reminders", isOn: $preferences.meditationEnabled)
                if preferences.meditationEnabled {
                    timePicker(hour: $preferences.meditationHour, minute: $preferences.meditationMinute)
                }
            }

            Section {
                Toggle("Daily check-in", isOn: $preferences.dailyCheckInEnabled)
                if preferences.dailyCheckInEnabled {
                    timePicker(hour: $preferences.dailyCheckInHour, minute: $preferences.dailyCheckInMinute)
                }
            } footer: {
                Text("A gentle nudge to check in with Journal.")
            }

            Section {
                Toggle("Private notification text", isOn: $preferences.privacyModeEnabled)
            } footer: {
                Text("When on, notifications avoid naming specific medications or tasks — useful if others might see your lock screen.")
            }
        }
        .navigationTitle("Notifications")
        .onAppear {
            coordinator.requestAuthorizationIfNeeded()
        }
    }

    private func timePicker(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        DatePicker(
            "Time",
            selection: Binding(
                get: {
                    var components = DateComponents()
                    components.hour = hour.wrappedValue
                    components.minute = minute.wrappedValue
                    return Calendar.current.date(from: components) ?? Date()
                },
                set: { newDate in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    hour.wrappedValue = components.hour ?? 9
                    minute.wrappedValue = components.minute ?? 0
                }
            ),
            displayedComponents: .hourAndMinute
        )
    }
}

#Preview {
    let preferences = NotificationPreferencesStore()
    let taskStore = TaskStore()
    let medicationStore = MedicationStore()
    return NavigationStack {
        NotificationSettingsView()
            .environmentObject(preferences)
            .environmentObject(NotificationCoordinator(
                scheduler: NotificationService(),
                preferences: preferences,
                taskStore: taskStore,
                medicationStore: medicationStore
            ))
    }
}
