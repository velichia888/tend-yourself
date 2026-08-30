import SwiftUI

struct GardenView: View {
    @EnvironmentObject private var store: WaterLogStore
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text(monthTitle)
                        .font(Theme.Font.headline(20))
                        .foregroundStyle(Theme.ink)

                    LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                        ForEach(daysInMonth, id: \.self) { day in
                            dayCell(for: day)
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .cardStyle()

                    Text("\(store.qualifyingDays.count) day\(store.qualifyingDays.count == 1 ? "" : "s") bloomed all-time \u{2022} longest streak \(store.longestStreak)")
                        .font(Theme.Font.body(13))
                        .foregroundStyle(Theme.inkSoft)
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Garden")
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    /// Every calendar-day start date in the current month, in order.
    private var daysInMonth: [Date] {
        let now = Date()
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: now),
            let dayCount = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day
        else { return [] }

        return (0..<dayCount).compactMap {
            calendar.date(byAdding: .day, value: $0, to: monthInterval.start)
        }
    }

    private func dayCell(for day: Date) -> some View {
        let qualifies = store.qualifyingDays.contains(calendar.startOfDay(for: day))
        let isToday = calendar.isDateInToday(day)
        let dayNumber = calendar.component(.day, from: day)

        return VStack(spacing: 2) {
            Circle()
                .fill(qualifies ? Theme.color(for: .fullBloom) : Theme.canvasSoft)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle()
                        .stroke(isToday ? Theme.accent : .clear, lineWidth: 2)
                        .frame(width: 30, height: 30)
                )

            Text("\(dayNumber)")
                .font(Theme.Font.body(10))
                .foregroundStyle(Theme.inkFaint)
        }
    }
}

#Preview {
    GardenView().environmentObject(WaterLogStore())
}
