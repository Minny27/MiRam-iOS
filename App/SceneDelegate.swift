import UIKit
import SwiftUI
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: AppWindow?

    private let alarmStateManager = AlarmStateManager()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let container = Self.makeModelContainer()
        let appWindow = AppWindow(windowScene: windowScene)
        appWindow.configure(
            with: MainRoute()
                .environmentObject(alarmStateManager)
                .modelContainer(container)
        )
        self.window = appWindow
    }

    /// 앱이 활성화될 때마다 전달된 알람 알림을 확인 (백그라운드에서 직접 진입하는 경우 처리)
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard alarmStateManager.firingAlarm == nil else { return }
        checkDeliveredAlarms()
    }

    // MARK: - Private

    /// 알림 센터에 남아있는 알람 알림을 확인하여 아직 울림 시간 내라면 발화
    private func checkDeliveredAlarms() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let now = Date()
            for notification in notifications {
                let userInfo = notification.request.content.userInfo
                guard let alarmId = userInfo["alarmId"] as? String,
                      let ringDuration = userInfo["ringDuration"] as? Int else { continue }

                let elapsed = Int(now.timeIntervalSince(notification.date))
                let remaining = ringDuration - elapsed

                // 울림 시간이 지났으면 알림만 제거
                guard remaining > 0 else {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(
                        withIdentifiers: [notification.request.identifier]
                    )
                    continue
                }

                let soundName = userInfo["soundName"] as? String ?? AlarmSound.default.id
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .alarmDidFire,
                        object: nil,
                        userInfo: ["alarmId": alarmId, "ringDuration": remaining, "soundName": soundName]
                    )
                }
                UNUserNotificationCenter.current().removeDeliveredNotifications(
                    withIdentifiers: [notification.request.identifier]
                )
            }
        }
    }

    /// ModelContainer 생성. 마이그레이션 실패 시 기존 store를 삭제하고 재생성한다.
    private static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: Alarm.self)
        } catch {
            let supportDir = URL.applicationSupportDirectory
            for name in ["default.store", "default.store-wal", "default.store-shm"] {
                try? FileManager.default.removeItem(at: supportDir.appending(path: name))
            }
            return try! ModelContainer(for: Alarm.self)
        }
    }
}
