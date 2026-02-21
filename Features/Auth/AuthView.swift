import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("로그인")
                .font(.largeTitle.bold())

            Button("시작하기", action: onLoginSuccess)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}
