import Foundation
import Combine
import AVFoundation

@MainActor
final class AlarmRingingViewModel: ObservableObject {
    @Published var remainingSeconds: Int
    @Published var isDismissed = false

    private let ringDuration: Int
    private var timerCancellable: AnyCancellable?
    private var audioPlayer: AVAudioPlayer?

    init(ringDuration: Int) {
        self.ringDuration = ringDuration
        self.remainingSeconds = ringDuration
        startAudio()
        startCountdown()
    }

    func dismiss() {
        stopTimer()
        stopAudio()
        isDismissed = true
    }

    // MARK: - Private

    private func startCountdown() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.dismiss()
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func startAudio() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3")
                ?? Bundle.main.url(forResource: "alarm", withExtension: "caf") else {
            // 시스템 사운드 fallback은 UNNotification이 처리
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            // 오디오 재생 실패 시 무음으로 진행
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    var progressFraction: Double {
        guard ringDuration > 0 else { return 0 }
        return Double(remainingSeconds) / Double(ringDuration)
    }

    var remainingLabel: String {
        RingDuration.label(for: remainingSeconds)
    }
}
