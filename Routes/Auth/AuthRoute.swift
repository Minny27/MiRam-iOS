import SwiftUI

enum AuthDestination: Hashable {
    case login
    case signUp
}

struct AuthRoute: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            AuthView(onLoginSuccess: {
                path.append(AuthDestination.login)
            })
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .login:
                    AuthView(onLoginSuccess: {})
                case .signUp:
                    EmptyView()
                }
            }
        }
    }
}
