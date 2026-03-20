import Foundation
import ActivityKit
import AlarmKit
import SwiftUI

final class AlarmScheduler {
    enum SchedulerError: LocalizedError {
        case authorizationDenied
        case authorizationRejected

        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "시스템 설정에서 알람 권한이 꺼져 있습니다. 설정에서 MiRam의 알람 권한을 허용해 주세요."
            case .authorizationRejected:
                return "AlarmKit 권한을 허용해야 알람을 예약할 수 있습니다."
            }
        }
    }

    private let manager = AlarmManager.shared

    var isAuthorizationDenied: Bool {
        manager.authorizationState == .denied
    }

    func requestAuthorizationIfNeeded() async throws -> Bool {
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            throw SchedulerError.authorizationDenied
        case .notDetermined:
            let state = try await manager.requestAuthorization()
            guard state == .authorized else {
                throw SchedulerError.authorizationRejected
            }
            return true
        @unknown default:
            throw SchedulerError.authorizationRejected
        }
    }

    func schedule(_ alarm: Alarm) async throws {
        guard alarm.isEnabled else {
            cancel(alarm)
            return
        }

        _ = try await requestAuthorizationIfNeeded()
        cancel(alarm)

        let attributes = AlarmAttributes(
            presentation: AlarmPresentation(alert: makeAlertPresentation()),
            metadata: MiRamAlarmMetadata(
                title: alarm.displayLabel,
                repeatDescription: alarm.repeatDescription,
                ringDuration: RingDuration.normalize(alarm.ringDuration)
            ),
            tintColor: .orange
        )

        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: .init(
                preAlert: nil,
                postAlert: TimeInterval(RingDuration.normalize(alarm.ringDuration))
            ),
            schedule: makeSchedule(for: alarm),
            attributes: attributes,
            sound: alertSound(for: alarm)
        )

        _ = try await manager.schedule(id: alarm.id, configuration: configuration)
    }

    func cancel(_ alarm: Alarm) {
        try? manager.cancel(id: alarm.id)
    }

    private func makeSchedule(for alarm: Alarm) -> AlarmKit.Alarm.Schedule {
        if alarm.repeatDays.isEmpty {
            return .fixed(alarm.nextTriggerDate())
        }

        return .relative(
            .init(
                time: .init(hour: alarm.hour, minute: alarm.minute),
                repeats: .weekly(alarm.repeatDays.map(\.localeWeekday))
            )
        )
    }

    private func makeAlertPresentation() -> AlarmPresentation.Alert {
        if #available(iOS 26.1, *) {
            return .init(title: "MiRam 알람")
        }

        return .init(
            title: "MiRam 알람",
            stopButton: AlarmButton(
                text: "중지",
                textColor: .white,
                systemImageName: "stop.circle.fill"
            )
        )
    }

    private func alertSound(for alarm: Alarm) -> AlertConfiguration.AlertSound {
        let sound = AlarmSound.named(alarm.soundName)
        if Bundle.main.url(forResource: sound.id, withExtension: "caf") != nil {
            return .named("\(sound.id).caf")
        }
        return .default
    }
}

private struct MiRamAlarmMetadata: AlarmMetadata {
    let title: String
    let repeatDescription: String
    let ringDuration: Int
}

private extension Weekday {
    var localeWeekday: Locale.Weekday {
        switch self {
        case .sun: return .sunday
        case .mon: return .monday
        case .tue: return .tuesday
        case .wed: return .wednesday
        case .thu: return .thursday
        case .fri: return .friday
        case .sat: return .saturday
        }
    }
}
