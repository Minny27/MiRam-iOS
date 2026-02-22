import SwiftUI

struct AlarmRingingView: View {
    let alarmId: String
    let soundName: String
    let ringDuration: Int
    let onDismiss: () -> Void

    @StateObject private var viewModel: AlarmRingingViewModel

    init(alarmId: String, soundName: String, ringDuration: Int, onDismiss: @escaping () -> Void) {
        self.alarmId = alarmId
        self.soundName = soundName
        self.ringDuration = ringDuration
        self.onDismiss = onDismiss
        _viewModel = StateObject(
            wrappedValue: AlarmRingingViewModel(soundName: soundName, ringDuration: ringDuration)
        )
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Image(systemName: "alarm.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating)

                VStack(spacing: 8) {
                    Text("알람")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(viewModel.remainingLabel)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                }

                ProgressView(value: viewModel.progressFraction)
                    .progressViewStyle(.linear)
                    .tint(.orange)
                    .padding(.horizontal, 40)

                Spacer()

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
            if dismissed { onDismiss() }
        }
    }
}
