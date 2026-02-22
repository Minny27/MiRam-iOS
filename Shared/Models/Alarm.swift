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
    /// 초 단위 (10~3600, 10초 단위)
    var ringDuration: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        repeatDays: [Weekday] = [],
        label: String = "",
        isEnabled: Bool = true,
        ringDuration: Int = 60,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.repeatDayRaws = repeatDays.map(\.rawValue)
        self.label = label
        self.isEnabled = isEnabled
        self.ringDuration = ringDuration
        self.createdAt = createdAt
    }

    var repeatDays: [Weekday] {
        get { repeatDayRaws.compactMap { Weekday(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue } }
        set { repeatDayRaws = newValue.map(\.rawValue) }
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var isOneTime: Bool { repeatDays.isEmpty }
}
