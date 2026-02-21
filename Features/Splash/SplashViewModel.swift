import Foundation
import Combine

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var isReady = false

    func checkInitialRoute() {
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isReady = true
        }
    }
}
