import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            Text("MiRam")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
        .onAppear {
            viewModel.checkInitialRoute()
        }
    }
}
