import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: WaterLogStore
    @State private var customAmountText = ""
    @FocusState private var customFieldFocused: Bool

    private let quickAmounts = [125, 250, 500]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    FlowerView(stage: store.todayStage)
                        .padding(.top, Theme.Spacing.md)

                    progressCard
                    streakCard
                    logControls
                    disclosureNote
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Tend")
        }
    }

    private var progressCard: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("\(store.todayTotalML) / \(store.dailyGoalML) ml")
                .font(Theme.Font.headline(22))
                .foregroundStyle(Theme.ink)

            ProgressView(value: min(store.todayPercent, 100), total: 100)
                .tint(Theme.color(for: store.todayStage))
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var streakCard: some View {
        HStack(spacing: Theme.Spacing.lg) {
            statBlock(label: "Current Streak", value: store.currentStreak)
            Divider().frame(height: 32)
            statBlock(label: "Longest Streak", value: store.longestStreak)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func statBlock(label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(Theme.Font.headline(24))
                .foregroundStyle(Theme.accent)
            Text(label)
                .font(Theme.Font.body(12))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }

    private var logControls: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Log Water")
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(quickAmounts, id: \.self) { amount in
                    Button {
                        store.logWater(amountML: amount)
                    } label: {
                        Text("+\(amount) ml")
                            .font(Theme.Font.body(14))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                }
            }

            HStack(spacing: Theme.Spacing.sm) {
                TextField("Custom ml", text: $customAmountText)
                    .keyboardType(.numberPad)
                    .focused($customFieldFocused)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))

                Button("Add") {
                    if let amount = Int(customAmountText), amount > 0 {
                        store.logWater(amountML: amount)
                        customAmountText = ""
                        customFieldFocused = false
                    }
                }
                .buttonStyle(.bordered)
                .disabled(Int(customAmountText).map { $0 <= 0 } ?? true)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }

    private var disclosureNote: some View {
        Text("Your flower grows from water you actually log — no points, no shortcuts. Missing a day just means a fresh seed tomorrow.")
            .font(Theme.Font.body(12))
            .foregroundStyle(Theme.inkFaint)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Theme.Spacing.md)
    }
}

#Preview {
    HomeView().environmentObject(WaterLogStore())
}
