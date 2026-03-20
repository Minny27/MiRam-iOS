import SwiftUI

enum MainDestination: Hashable {
    case home
    case alarmDetail(AlarmDetailMode)
}

// AlarmDetailMode Hashable 적합
extension AlarmDetailMode: Hashable {
    static func == (lhs: AlarmDetailMode, rhs: AlarmDetailMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add): return true
        case (.edit(let a), .edit(let b)): return a.id == b.id
        default: return false
        }
    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .add: hasher.combine(0)
        case .edit(let a): hasher.combine(1); hasher.combine(a.id)
        }
    }
}

struct MainRoute: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}
