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
            ringDuration = 60
            soundName = AlarmSound.default.id
        case .edit(let alarm):
            hour = alarm.hour
            minute = alarm.minute
            label = alarm.label
            selectedDays = Set(alarm.repeatDays)
            ringDuration = alarm.ringDuration
            soundName = alarm.soundName
        }
    }

    func save(context: ModelContext) throws {
        switch mode {
        case .add:
            let alarm = Alarm(
                hour: hour,
                minute: minute,
                repeatDays: Array(selectedDays),
                label: label,
                isEnabled: true,
                ringDuration: ringDuration,
                soundName: soundName
            )
            context.insert(alarm)
            try context.save()
            scheduler.schedule(alarm)
        case .edit(let alarm):
            alarm.hour = hour
            alarm.minute = minute
            alarm.repeatDays = Array(selectedDays)
            alarm.label = label
            alarm.ringDuration = ringDuration
            alarm.soundName = soundName
            try context.save()
            scheduler.cancel(alarm)
            scheduler.schedule(alarm)
        }
    }
}
