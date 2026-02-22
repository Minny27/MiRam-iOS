import Foundation
import AudioToolbox
import UserNotifications

/// 알람 사운드 옵션 정의
/// - 번들에 동일한 id의 .mp3/.caf 파일이 있으면 AVAudioPlayer로 재생
/// - 없으면 AudioServicesPlaySystemSound 루프로 fallback
struct AlarmSound: Identifiable, Hashable {
    let id: String
    let displayName: String
    /// AudioServices fallback용 시스템 사운드 ID (1005 = iOS 기본 알람 비프)
    let systemSoundID: SystemSoundID

    // MARK: - 사운드 목록

    static let all: [AlarmSound] = [
        .init(id: "classic",   displayName: "클래식",  systemSoundID: 1005),
        .init(id: "bell",      displayName: "벨",     systemSoundID: 1013),
        .init(id: "digital",   displayName: "디지털",  systemSoundID: 1022),
        .init(id: "ascending", displayName: "어센딩",  systemSoundID: 1036),
    ]

    static let `default` = all[0]

    static func named(_ name: String) -> AlarmSound {
        all.first { $0.id == name } ?? .default
    }

    // MARK: - 알림 사운드

    /// 로컬 알림에 사용할 사운드
    /// 번들에 "{id}.caf" 파일이 있으면 커스텀, 없으면 defaultCritical
    var notificationSound: UNNotificationSound {
        let cafName = "\(id).caf"
        if Bundle.main.url(forResource: id, withExtension: "caf") != nil
            || Bundle.main.url(forResource: id, withExtension: "mp3") != nil {
            return UNNotificationSound(named: UNNotificationSoundName(cafName))
        }
        return .defaultCritical
    }

    // MARK: - 인앱 재생

    /// AVAudioPlayer용 URL - 번들 파일 우선, 없으면 nil (→ AudioServices fallback)
    var bundleURL: URL? {
        Bundle.main.url(forResource: id, withExtension: "mp3")
            ?? Bundle.main.url(forResource: id, withExtension: "caf")
    }

    /// 미리 듣기용 1회 재생 (AlarmDetail 픽커에서 사용)
    func playOnce() {
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
