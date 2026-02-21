import SwiftUI

enum MainDestination: Hashable {
    case home
}

struct MainRoute: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: MainDestination.self) { destination in
                    switch destination {
                    case .home:
                        HomeView()
                    }
                }
        }
    }
}
