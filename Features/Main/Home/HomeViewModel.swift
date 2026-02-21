import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
}
