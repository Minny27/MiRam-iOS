import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Task {
            try? await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 앱이 포그라운드 상태일 때 알림 수신 → 즉시 알람 화면 표시 (배너 생략)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        fireAlarm(from: notification.request.content.userInfo)
        completionHandler([]) // 배너 없이 AlarmRingingView가 처리
    }

    /// 백그라운드에서 알림을 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        fireAlarm(from: response.notification.request.content.userInfo)
        completionHandler()
    }

    func fireAlarm(from userInfo: [AnyHashable: Any]) {
        guard let alarmId = userInfo["alarmId"] as? String,
              let ringDuration = userInfo["ringDuration"] as? Int else { return }
        let soundName = userInfo["soundName"] as? String ?? AlarmSound.default.id
        NotificationCenter.default.post(
            name: .alarmDidFire,
            object: nil,
            userInfo: ["alarmId": alarmId, "ringDuration": ringDuration, "soundName": soundName]
        )
    }
}

extension Notification.Name {
    static let alarmDidFire = Notification.Name("alarmDidFire")
}
