import SwiftUI

enum MainDestination: Hashable {
    case home
    case alarmDetail(AlarmDetailMode)
    case alarmRinging(alarmId: String, ringDuration: Int)
}

// AlarmDetailMode는 Equatable/Hashable 필요
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
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: MainDestination.self) { destination in
                    switch destination {
                    case .home:
                        HomeView()
                    case .alarmDetail(let mode):
                        AlarmDetailView(mode: mode)
                    case .alarmRinging(let alarmId, let ringDuration):
                        AlarmRingingView(alarmId: alarmId, ringDuration: ringDuration)
                    }
                }
        }
    }
}
