import Foundation
import Combine
import AVFoundation

@MainActor
final class AlarmRingingViewModel: ObservableObject {
    @Published var remainingSeconds: Int
    @Published var isDismissed = false

    private let sound: AlarmSound
    private let ringDuration: Int
    private var timerCancellable: AnyCancellable?
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?

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
        // .playback 카테고리: 무음 모드에서도 재생
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        // 번들 파일이 있으면 AVAudioPlayer로 루프 재생
        if let url = sound.bundleURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = -1
            player.play()
            audioPlayer = player
            return
        }

        // 번들 파일 없음 → AVAudioEngine으로 알람 비프음 합성
        startSynthesizedTone()
    }

    /// AVAudioEngine으로 880Hz 비프(0.4s on / 0.6s off) 패턴을 루프 재생
    private func startSynthesizedTone() {
        let engine = AVAudioEngine()
        let mixer = engine.mainMixerNode
        let sampleRate = mixer.outputFormat(forBus: 0).sampleRate

        let beepDur  = 0.4
        let totalDur = 1.0   // 0.4s 비프 + 0.6s 무음
        let totalFrames = Int(sampleRate * totalDur)
        let beepFrames  = Int(sampleRate * beepDur)
        let freq = 880.0

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                            frameCapacity: AVAudioFrameCount(totalFrames)) else { return }
        buffer.frameLength = AVAudioFrameCount(totalFrames)

        let ptr = buffer.floatChannelData![0]
        for i in 0..<totalFrames {
            if i < beepFrames {
                // 앞뒤 10ms 페이드로 클릭 노이즈 제거
                let fadeLen = sampleRate * 0.01
                let env = min(Double(i) / fadeLen, 1.0) * min(Double(beepFrames - i) / fadeLen, 1.0)
                ptr[i] = Float(sin(2.0 * .pi * freq * Double(i) / sampleRate) * env * 0.8)
            } else {
                ptr[i] = 0.0
            }
        }

        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixer, format: format)

        do {
            try engine.start()
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
            playerNode.play()
            audioEngine = engine
        } catch {
            // 엔진 시작 실패 시 무시 (알림 사운드가 이미 울렸으므로 UI는 정상 동작)
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioEngine?.stop()
        audioEngine = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
