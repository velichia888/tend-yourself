import SwiftUI

struct MedicationView: View {
    @EnvironmentObject private var store: MedicationStore
    @State private var showingAddMedication = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                header
                completedCard

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text("Today's medications")
                            .font(Theme.Font.headline(16))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Text(Date(), format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                            .font(Theme.Font.body(13))
                            .foregroundStyle(Theme.inkSoft)
                    }

                    if store.todaysDoses.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.todaysDoses) { dose in
                            doseRow(dose)
                        }
                    }
                }

                if !store.medicationsNeedingRefill.isEmpty {
                    refillSection
                }

                NavigationLink {
                    MedicationHistoryView()
                } label: {
                    IconBadgeCard(category: .medication, icon: "chart.bar.fill", title: "Medication history", subtitle: "View past 30 days") {
                        Image(systemName: "chevron.right").foregroundStyle(Theme.inkFaint)
                    }
                }
                .buttonStyle(.plain)

                Text(MedicationCopy.disclosure)
                    .font(Theme.Font.body(12))
                    .foregroundStyle(Theme.inkFaint)
                    .multilineTextAlignment(.center)

                addButton
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Medication")
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView().environmentObject(store)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Medication")
                .font(Theme.Font.display(30))
                .foregroundStyle(Theme.ink)
            Text("Small steps keep you steady.")
                .font(Theme.Font.script(18))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var completedCard: some View {
        let (completed, total) = store.todaysCompletedCount
        return IconBadgeCard(
            category: .medication,
            icon: "leaf.fill",
            title: "\(completed) of \(total) completed today",
            subtitle: total == 0 ? "Add a medication to get started" : "Small steps make a big difference."
        )
    }

    private func doseRow(_ dose: MedicationEngine.Dose) -> some View {
        let status = store.status(for: dose)
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                IconBadge(category: .medication, icon: "pills.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text(dose.medication.name)
                        .font(Theme.Font.headline(16))
                        .foregroundStyle(Theme.ink)
                    Text(dose.medication.dose)
                        .font(Theme.Font.body(13))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                Text(dose.scheduledFor, format: .dateTime.hour().minute())
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Theme.inkSoft)
            }

            HStack(spacing: Theme.Spacing.sm) {
                statusButton("Taken", isActive: status == .taken, activeColor: Theme.success) {
                    store.recordDose(dose, status: .taken)
                }
                statusButton("Later", isActive: status == .later, activeColor: Theme.accent) {
                    store.recordDose(dose, status: .later)
                }
                statusButton("Skip", isActive: status == .skipped, activeColor: Theme.danger) {
                    store.recordDose(dose, status: .skipped)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private func statusButton(_ title: String, isActive: Bool, activeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Font.body(13))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.xs)
                .background(isActive ? activeColor.opacity(0.18) : Theme.canvasSoft)
                .foregroundStyle(isActive ? activeColor : Theme.inkSoft)
                .clipShape(Capsule())
        }
    }

    private var refillSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Refill reminders")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
            ForEach(store.medicationsNeedingRefill) { medication in
                IconBadgeCard(category: .medication, icon: "cross.case.fill", title: medication.name, subtitle: "\(medication.pillsRemaining ?? 0) left")
            }
        }
    }

    private var emptyState: some View {
        Text("No medications added yet. Add one below to start tracking your schedule.")
            .font(Theme.Font.body(14))
            .foregroundStyle(Theme.inkSoft)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
    }

    private var addButton: some View {
        Button {
            showingAddMedication = true
        } label: {
            Label("Add Medication", systemImage: "plus")
                .font(Theme.Font.headline(16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.accent)
    }
}

#Preview {
    NavigationStack {
        MedicationView().environmentObject(MedicationStore())
    }
}
