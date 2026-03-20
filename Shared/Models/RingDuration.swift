import Foundation

enum RingDuration {
    static let allValues: [Int] = [5, 10, 15, 20, 25, 30, 40, 50, 60]
    static let defaultValue = 60

    static func normalize(_ seconds: Int) -> Int {
        allValues.min(by: { abs($0 - seconds) < abs($1 - seconds) }) ?? defaultValue
    }

    static func label(for seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)초" }
        let m = seconds / 60
        let s = seconds % 60
        return s == 0 ? "\(m)분" : "\(m)분 \(s)초"
    }
}
