import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var hour: Int
    var minute: Int
    /// Weekday raw values stored as [Int] (빈 배열 = 1회성)
    var repeatDayRaws: [Int]
    var label: String
    var isEnabled: Bool
    /// 초 단위 (5~3600)
    var ringDuration: Int
    /// AlarmSound.id (예: "classic", "bell", ...)
    var soundName: String = "classic"
    var createdAt: Date

    init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        repeatDays: [Weekday] = [],
        label: String = "",
        isEnabled: Bool = true,
        ringDuration: Int = 60,
        soundName: String = AlarmSound.default.id,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.repeatDayRaws = repeatDays.map(\.rawValue)
        self.label = label
        self.isEnabled = isEnabled
        self.ringDuration = ringDuration
        self.soundName = soundName
        self.createdAt = createdAt
    }

    var repeatDays: [Weekday] {
        get { repeatDayRaws.compactMap { Weekday(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue } }
        set { repeatDayRaws = newValue.map(\.rawValue) }
    }

    /// 24시간 포맷 (예: "08:30")
    var timeString: String { String(format: "%02d:%02d", hour, minute) }

    /// 12시간 포맷 (예: "08:30")
    var twelveHourTimeString: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%02d:%02d", h, minute)
    }

    /// AM / PM
    var amPm: String { hour < 12 ? "AM" : "PM" }

    var isOneTime: Bool { repeatDays.isEmpty }
}
