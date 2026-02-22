import SwiftUI

struct AlarmRingingView: View {
    let alarmId: String
    let ringDuration: Int

    @StateObject private var viewModel: AlarmRingingViewModel
    @Environment(\.dismiss) private var dismiss

    init(alarmId: String, ringDuration: Int) {
        self.alarmId = alarmId
        self.ringDuration = ringDuration
        _viewModel = StateObject(wrappedValue: AlarmRingingViewModel(ringDuration: ringDuration))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 알람 아이콘
                Image(systemName: "alarm.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating)

                // 남은 시간
                VStack(spacing: 8) {
                    Text("알람")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(viewModel.remainingLabel)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                }

                // 진행 바
                ProgressView(value: viewModel.progressFraction)
                    .progressViewStyle(.linear)
                    .tint(.orange)
                    .padding(.horizontal, 40)

                Spacer()

                // 해제 버튼
                Button {
                    viewModel.dismiss()
                } label: {
                    Text("알람 해제")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isDismissed) { _, dismissed in
            if dismissed { dismiss() }
        }
    }
}
