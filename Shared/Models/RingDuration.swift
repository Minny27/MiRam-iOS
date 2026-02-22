import Foundation

enum RingDuration {
    /// 5초~30초 (5초 단위) + 40초~3600초 (10초 단위)
    static let allValues: [Int] =
        Array(stride(from: 5, through: 30, by: 5)) +
        Array(stride(from: 40, through: 3600, by: 10))

    static func label(for seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)초" }
        let m = seconds / 60
        let s = seconds % 60
        return s == 0 ? "\(m)분" : "\(m)분 \(s)초"
    }
}
