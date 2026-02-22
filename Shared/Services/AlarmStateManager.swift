import Foundation
import Combine

/// 알람 발화 이벤트를 UI로 브리지하는 매니저
/// AppDelegate에서 NotificationCenter 포스트 → 여기서 수신 → SwiftUI .fullScreenCover 트리거
@MainActor
final class AlarmStateManager: ObservableObject {

    struct FiringAlarm: Identifiable {
        let id: String          // alarmId
        let soundName: String
        let ringDuration: Int
    }

    @Published var firingAlarm: FiringAlarm? = nil

    private var observer: NSObjectProtocol?

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: .alarmDidFire,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let userInfo = notification.userInfo,
                let alarmId = userInfo["alarmId"] as? String,
                let ringDuration = userInfo["ringDuration"] as? Int
            else { return }
            let soundName = userInfo["soundName"] as? String ?? AlarmSound.default.id
            Task { @MainActor [weak self] in
                guard let self else { return }
                // 이미 같은 알람이 울리고 있으면 중복 발화 무시
                guard self.firingAlarm?.id != alarmId else { return }
                self.firingAlarm = FiringAlarm(
                    id: alarmId,
                    soundName: soundName,
                    ringDuration: ringDuration
                )
            }
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }
}
