import SwiftUI

struct AddMedicationView: View {
    @EnvironmentObject private var store: MedicationStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dose = ""
    @State private var scheduleTimes: [Date] = [Date()]
    @State private var trackRefills = false
    @State private var pillsRemaining = 30
    @State private var refillThreshold = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    TextField("Name", text: $name)
                    TextField("Dose (e.g. 50 mg)", text: $dose)
                }

                Section("Schedule") {
                    ForEach(scheduleTimes.indices, id: \.self) { index in
                        DatePicker("Time \(index + 1)", selection: $scheduleTimes[index], displayedComponents: .hourAndMinute)
                    }
                    .onDelete { scheduleTimes.remove(atOffsets: $0) }
                    Button("Add another time") { scheduleTimes.append(Date()) }
                }

                Section("Refill tracking") {
                    Toggle("Track pills remaining", isOn: $trackRefills)
                    if trackRefills {
                        Stepper("Pills remaining: \(pillsRemaining)", value: $pillsRemaining, in: 0...500)
                        Stepper("Remind when at or below: \(refillThreshold)", value: $refillThreshold, in: 0...50)
                    }
                }
            }
            .navigationTitle("Add Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addMedication() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addMedication() {
        let calendar = Calendar.current
        let components = scheduleTimes.map { calendar.dateComponents([.hour, .minute], from: $0) }

        store.addMedication(Medication(
            name: name,
            dose: dose,
            scheduleTimes: components,
            pillsRemaining: trackRefills ? pillsRemaining : nil,
            refillReminderThreshold: trackRefills ? refillThreshold : nil
        ))
        dismiss()
    }
}

#Preview {
    AddMedicationView().environmentObject(MedicationStore())
}
