import Foundation
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published private(set) var authorizationDenied = false

    private let scheduler = AlarmScheduler()

    func prepare() {
        authorizationDenied = scheduler.isAuthorizationDenied
    }

    func deleteAlarm(_ alarm: Alarm, context: ModelContext) {
        scheduler.cancel(alarm)
        context.delete(alarm)
        try? context.save()
    }

    func toggleEnabled(_ alarm: Alarm, context: ModelContext) async {
        let originalValue = alarm.isEnabled
        alarm.isEnabled.toggle()

        do {
            if alarm.isEnabled {
                try await scheduler.schedule(alarm)
            } else {
                scheduler.cancel(alarm)
            }
            try context.save()
        } catch {
            alarm.isEnabled = originalValue
            errorMessage = error.localizedDescription
        }

        authorizationDenied = scheduler.isAuthorizationDenied
    }
}
