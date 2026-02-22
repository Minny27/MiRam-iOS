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
        let appWindow = AppWindow(windowScene: windowScene)
        appWindow.configure(
            with: MainRoute()
                .environmentObject(alarmStateManager)
                .modelContainer(for: Alarm.self)
        )
        self.window = appWindow
    }
}
