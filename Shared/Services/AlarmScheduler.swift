import Foundation
import UserNotifications

final class AlarmScheduler {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
        } catch {
            return false
        }
    }

    func schedule(_ alarm: Alarm) {
        cancel(alarm)
        guard alarm.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "알람" : alarm.label
        content.body = alarm.timeString
        content.sound = AlarmSound.named(alarm.soundName).notificationSound
        content.userInfo = [
            "alarmId": alarm.id.uuidString,
            "ringDuration": alarm.ringDuration,
            "soundName": alarm.soundName
        ]

        if alarm.isOneTime {
            scheduleOnce(alarm: alarm, content: content)
        } else {
            alarm.repeatDays.forEach { scheduleRepeating(alarm: alarm, weekday: $0, content: content) }
        }
    }

    func cancel(_ alarm: Alarm) {
        var ids = [oneTimeIdentifier(alarm)]
        Weekday.allCases.forEach { ids.append(repeatingIdentifier(alarm, weekday: $0)) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    // MARK: - Private

    private func scheduleOnce(alarm: Alarm, content: UNMutableNotificationContent) {
        var components = DateComponents()
        components.hour = alarm.hour
        components.minute = alarm.minute
        components.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: oneTimeIdentifier(alarm), content: content, trigger: trigger)) { _ in }
    }

    private func scheduleRepeating(alarm: Alarm, weekday: Weekday, content: UNMutableNotificationContent) {
        var components = DateComponents()
        components.weekday = weekday.calendarWeekday
        components.hour = alarm.hour
        components.minute = alarm.minute
        components.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: repeatingIdentifier(alarm, weekday: weekday), content: content, trigger: trigger)) { _ in }
    }

    private func oneTimeIdentifier(_ alarm: Alarm) -> String { "\(alarm.id.uuidString)-once" }
    private func repeatingIdentifier(_ alarm: Alarm, weekday: Weekday) -> String { "\(alarm.id.uuidString)-repeat-\(weekday.rawValue)" }
}
