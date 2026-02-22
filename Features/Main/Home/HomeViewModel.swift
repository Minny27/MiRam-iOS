import Foundation
import SwiftData
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var errorMessage: String?

    private let repository: AlarmRepository

    init(repository: AlarmRepository = DIContainer.shared.alarmRepository) {
        self.repository = repository
        loadAlarms()
    }

    func loadAlarms() {
        do {
            alarms = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        do {
            try repository.delete(alarm)
            loadAlarms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleEnabled(_ alarm: Alarm) {
        do {
            try repository.setEnabled(alarm, enabled: !alarm.isEnabled)
            loadAlarms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
