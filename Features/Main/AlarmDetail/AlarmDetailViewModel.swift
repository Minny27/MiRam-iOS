import Foundation
import SwiftUI

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
    @Published var errorMessage: String?

    private let mode: AlarmDetailMode
    private let repository: AlarmRepository

    init(mode: AlarmDetailMode, repository: AlarmRepository = DIContainer.shared.alarmRepository) {
        self.mode = mode
        self.repository = repository

        switch mode {
        case .add:
            let calendar = Calendar.current
            let now = Date()
            hour = calendar.component(.hour, from: now)
            minute = calendar.component(.minute, from: now)
            label = ""
            selectedDays = []
            ringDuration = 60
        case .edit(let alarm):
            hour = alarm.hour
            minute = alarm.minute
            label = alarm.label
            selectedDays = Set(alarm.repeatDays)
            ringDuration = alarm.ringDuration
        }
    }

    func save() throws {
        switch mode {
        case .add:
            let alarm = Alarm(
                hour: hour,
                minute: minute,
                repeatDays: Array(selectedDays),
                label: label,
                isEnabled: true,
                ringDuration: ringDuration
            )
            try repository.add(alarm)
        case .edit(let alarm):
            alarm.hour = hour
            alarm.minute = minute
            alarm.repeatDays = Array(selectedDays)
            alarm.label = label
            alarm.ringDuration = ringDuration
            try repository.update(alarm)
        }
    }
}
