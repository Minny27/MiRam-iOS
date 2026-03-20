import UIKit
import SwiftUI
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: AppWindow?

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
                .modelContainer(container)
        )
        self.window = appWindow
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
