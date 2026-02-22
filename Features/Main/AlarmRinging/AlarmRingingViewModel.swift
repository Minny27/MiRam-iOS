import Foundation
import Combine
import AVFoundation
import AudioToolbox

@MainActor
final class AlarmRingingViewModel: ObservableObject {
    @Published var remainingSeconds: Int
    @Published var isDismissed = false

    private let sound: AlarmSound
    private let ringDuration: Int
    private var timerCancellable: AnyCancellable?
    private var audioPlayer: AVAudioPlayer?
    private var soundLoopTimer: Timer?

    init(soundName: String, ringDuration: Int) {
        self.sound = AlarmSound.named(soundName)
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

    var progressFraction: Double {
        guard ringDuration > 0 else { return 0 }
        return Double(remainingSeconds) / Double(ringDuration)
    }

    var remainingLabel: String { RingDuration.label(for: remainingSeconds) }

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
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            if let url = sound.bundleURL {
                // 번들에 커스텀 사운드 파일이 있으면 AVAudioPlayer로 루프 재생
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } else {
                // 번들 파일 없음 → AudioServicesPlaySystemSound 루프 (2초 간격)
                startSystemSoundLoop()
            }
        } catch {
            startSystemSoundLoop()
        }
    }

    private func startSystemSoundLoop() {
        sound.playOnce()
        soundLoopTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.sound.playOnce()
        }
    }

    private func stopAudio() {
        soundLoopTimer?.invalidate()
        soundLoopTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
