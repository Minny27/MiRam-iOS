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
            await DIContainer.shared.alarmScheduler.requestAuthorization()
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
    // 앱이 포그라운드 상태일 때도 알림 배너 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // 알림 탭 → AlarmRinging 화면으로 이동
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let alarmId = userInfo["alarmId"] as? String,
           let ringDuration = userInfo["ringDuration"] as? Int {
            NotificationCenter.default.post(
                name: .alarmDidFire,
                object: nil,
                userInfo: ["alarmId": alarmId, "ringDuration": ringDuration]
            )
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let alarmDidFire = Notification.Name("alarmDidFire")
}
