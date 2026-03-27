import Foundation
import UserNotifications

class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private static let categoryId    = "HABIT_CHECK_IN"
    private static let doneActionId  = "DONE"
    private static let missedActionId = "MISSED"
    private static let notificationId = "daily_habit"

    private override init() {
        super.init()
    }

    /// Call once at app launch to set this object as the notification delegate.
    func setupDelegate() {
        UNUserNotificationCenter.current().delegate = self
        registerActions()
    }

    private func registerActions() {
        let done   = UNNotificationAction(identifier: Self.doneActionId,   title: "✓ Done",   options: .foreground)
        let missed = UNNotificationAction(identifier: Self.missedActionId, title: "✗ Missed", options: .foreground)
        let cat = UNNotificationCategory(identifier: Self.categoryId, actions: [done, missed],
                                         intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([cat])
    }

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleNotification(habitName: String, time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])

        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body  = "Did you \(habitName) today?"
        content.sound = .default
        content.categoryIdentifier = categoryId

        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Foreground action tap → app is opening; write check-in, widget reloads.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Self.doneActionId:
            HabitStore().logCheckIn(value: true)
        case Self.missedActionId:
            HabitStore().logCheckIn(value: false)
        default:
            break
        }
        completionHandler()
    }

    /// Show banner even when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
