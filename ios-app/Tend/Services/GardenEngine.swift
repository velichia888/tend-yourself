import Foundation

/// Streak math over a set of qualifying calendar days (local midnight
/// `Date`s). Pure and deterministic — computed live from real data every
/// time, never cached as a driftable counter. See docs/GROWTH.md.
enum GardenEngine {
    static func currentStreak(qualifyingDays: Set<Date>, today: Date, calendar: Calendar = .current) -> Int {
        let todayStart = calendar.startOfDay(for: today)
        guard let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) else { return 0 }

        var streak = 0
        // Today is still "in progress" — only start counting from today
        // if it has already qualified; otherwise start from yesterday so
        // an incomplete today doesn't look like a broken streak.
        var cursor = qualifyingDays.contains(todayStart) ? todayStart : yesterdayStart

        while qualifyingDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    static func longestStreak(qualifyingDays: Set<Date>, calendar: Calendar = .current) -> Int {
        guard !qualifyingDays.isEmpty else { return 0 }
        let sorted = qualifyingDays.sorted()

        var longest = 1
        var current = 1
        for index in 1..<sorted.count {
            let previousDay = sorted[index - 1]
            let day = sorted[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previousDay),
               calendar.isDate(expected, inSameDayAs: day) {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
        }
        return longest
    }
}
