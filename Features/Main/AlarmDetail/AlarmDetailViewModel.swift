import Foundation
import SwiftData

enum AlarmDetailMode {
    case add
    case edit(Alarm)
}

@MainActor
final class AlarmDetailViewModel: ObservableObject {
    @Published var hour: Int
    @Published var minute: Int
    @Published var label: String
    @Published var selectedDays: Set<Weekday>
    @Published var ringDuration: Int
    @Published var soundName: String
    @Published var errorMessage: String?

    private let mode: AlarmDetailMode
    private let scheduler = AlarmScheduler()

    init(mode: AlarmDetailMode) {
        self.mode = mode

        switch mode {
        case .add:
            let now = Date()
            let cal = Calendar.current
            hour = cal.component(.hour, from: now)
            minute = cal.component(.minute, from: now)
            label = ""
            selectedDays = []
            ringDuration = RingDuration.defaultValue
            soundName = AlarmSound.default.id
        case .edit(let alarm):
            hour = alarm.hour
            minute = alarm.minute
            label = alarm.label
            selectedDays = Set(alarm.repeatDays)
            ringDuration = RingDuration.normalize(alarm.ringDuration)
            soundName = alarm.soundName
        }
    }

    var timePreview: String {
        String(format: "%02d:%02d", hour % 12 == 0 ? 12 : hour % 12, minute)
    }

    var amPm: String {
        hour < 12 ? "AM" : "PM"
    }

    func save(context: ModelContext) async throws {
        switch mode {
        case .add:
            let alarm = Alarm(
                hour: hour,
                minute: minute,
                repeatDays: Array(selectedDays),
                label: label,
                isEnabled: true,
                ringDuration: RingDuration.normalize(ringDuration),
                soundName: soundName
            )
            try await scheduler.schedule(alarm)
            context.insert(alarm)
            do {
                try context.save()
            } catch {
                scheduler.cancel(alarm)
                throw error
            }
        case .edit(let alarm):
            let snapshot = AlarmSnapshot(alarm: alarm)

            alarm.hour = hour
            alarm.minute = minute
            alarm.repeatDays = Array(selectedDays)
            alarm.label = label
            alarm.ringDuration = RingDuration.normalize(ringDuration)
            alarm.soundName = soundName

            do {
                if alarm.isEnabled {
                    try await scheduler.schedule(alarm)
                } else {
                    scheduler.cancel(alarm)
                }
                try context.save()
            } catch {
                snapshot.restore(on: alarm)
                if alarm.isEnabled {
                    try? await scheduler.schedule(alarm)
                } else {
                    scheduler.cancel(alarm)
                }
                throw error
            }
        }
    }
}

private struct AlarmSnapshot {
    let hour: Int
    let minute: Int
    let repeatDays: [Weekday]
    let label: String
    let ringDuration: Int
    let soundName: String
    let isEnabled: Bool

    init(alarm: Alarm) {
        hour = alarm.hour
        minute = alarm.minute
        repeatDays = alarm.repeatDays
        label = alarm.label
        ringDuration = alarm.ringDuration
        soundName = alarm.soundName
        isEnabled = alarm.isEnabled
    }

    func restore(on alarm: Alarm) {
        alarm.hour = hour
        alarm.minute = minute
        alarm.repeatDays = repeatDays
        alarm.label = label
        alarm.ringDuration = ringDuration
        alarm.soundName = soundName
        alarm.isEnabled = isEnabled
    }
}
