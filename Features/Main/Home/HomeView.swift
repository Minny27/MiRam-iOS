import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack {
            Text("홈")
                .font(.largeTitle.bold())
        }
        .navigationTitle("홈")
    }
}
