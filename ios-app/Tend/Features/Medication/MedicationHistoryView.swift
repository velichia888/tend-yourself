import SwiftUI

struct MedicationHistoryView: View {
    @EnvironmentObject private var store: MedicationStore

    private var recentEntries: [MedicationLogEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
        return store.log
            .filter { $0.scheduledFor >= cutoff }
            .sorted { $0.scheduledFor > $1.scheduledFor }
    }

    private func medicationName(for entry: MedicationLogEntry) -> String {
        store.medications.first { $0.id == entry.medicationID }?.name ?? "Medication"
    }

    var body: some View {
        List {
            if recentEntries.isEmpty {
                Text("No recorded doses in the past 30 days yet.")
                    .font(Theme.Font.body(14))
                    .foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(recentEntries) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(medicationName(for: entry))
                                .font(Theme.Font.headline(15))
                                .foregroundStyle(Theme.ink)
                            Text(entry.scheduledFor, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .font(Theme.Font.body(12))
                                .foregroundStyle(Theme.inkSoft)
                        }
                        Spacer()
                        Text(statusLabel(entry.status))
                            .font(Theme.Font.body(12))
                            .foregroundStyle(statusColor(entry.status))
                    }
                }
            }
        }
        .navigationTitle("Medication History")
        .background(Theme.canvas)
        .scrollContentBackground(.hidden)
    }

    private func statusLabel(_ status: MedicationDoseStatus) -> String {
        switch status {
        case .taken: return "Taken"
        case .later: return "Later"
        case .skipped: return "Skipped"
        case .pending: return "Pending"
        }
    }

    private func statusColor(_ status: MedicationDoseStatus) -> Color {
        switch status {
        case .taken: return Theme.success
        case .later: return Theme.accent
        case .skipped: return Theme.danger
        case .pending: return Theme.inkFaint
        }
    }
}

#Preview {
    NavigationStack {
        MedicationHistoryView().environmentObject(MedicationStore())
    }
}
