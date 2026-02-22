import Foundation

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case mon = 1, tue, wed, thu, fri, sat, sun

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        case .sun: return "일"
        }
    }

    /// Calendar weekday component (Sun=1 … Sat=7)
    var calendarWeekday: Int {
        switch self {
        case .sun: return 1
        case .mon: return 2
        case .tue: return 3
        case .wed: return 4
        case .thu: return 5
        case .fri: return 6
        case .sat: return 7
        }
    }
}
