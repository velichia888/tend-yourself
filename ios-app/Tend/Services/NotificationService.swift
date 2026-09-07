import Foundation
import UserNotifications

protocol NotificationScheduling {
    func requestAuthorization() async -> Bool
    func scheduleDaily(id: String, title: String, body: String, hour: Int, minute: Int)
    func scheduleOneShot(id: String, title: String, body: String, secondsFromNow: TimeInterval)
    func cancel(id: String)
    func cancel(idsWithPrefix prefix: String)
}

/// Thin wrapper over UNUserNotificationCenter. Local notifications only
/// — no remote push, no Info.plist usage-description key required.
struct NotificationService: NotificationScheduling {
    func requestAuthorization() async -> Bool {
        #if DEBUG
        // A real system permission alert on an unattended CI simulator
        // would hang the screenshot workflow the same way an unhandled
        // Face ID prompt would (see BiometricAuthService) — never call
        // the real API during automation.
        if ProcessInfo.processInfo.environment["IOS_TEST_AUTOMATION"] == "1" {
            return true
        }
        #endif
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleDaily(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleOneShot(id: String, title: String, body: String, secondsFromNow: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, secondsFromNow), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancel(idsWithPrefix prefix: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let matching = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            guard !matching.isEmpty else { return }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: matching)
        }
    }
}
