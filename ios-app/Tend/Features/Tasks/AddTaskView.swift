import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject private var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var subtitle = ""
    @State private var timeBlock: TaskItem.TimeBlock = .morning
    @State private var priority: TaskItem.Priority = .niceToDo
    @State private var recurrence: TaskItem.Recurrence = .none
    @State private var reminderEnabled = false
    @State private var reminderDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Note (optional)", text: $subtitle)
                }

                Section("When") {
                    Picker("Time of day", selection: $timeBlock) {
                        ForEach(TaskItem.TimeBlock.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Picker("Priority", selection: $priority) {
                        Text("Must do").tag(TaskItem.Priority.mustDo)
                        Text("Nice to do").tag(TaskItem.Priority.niceToDo)
                    }
                    Toggle("Repeats daily", isOn: Binding(
                        get: { recurrence == .daily },
                        set: { recurrence = $0 ? .daily : .none }
                    ))
                }

                Section("Reminder") {
                    Toggle("Remind me", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Add a Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addTask() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let reminder: DateComponents? = reminderEnabled
            ? Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
            : nil

        store.addTask(
            title: title,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            timeBlock: timeBlock,
            priority: priority,
            recurrence: recurrence,
            reminderTime: reminder
        )
        dismiss()
    }
}

#Preview {
    AddTaskView().environmentObject(TaskStore())
}
