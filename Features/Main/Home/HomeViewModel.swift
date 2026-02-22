import Foundation
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    private let scheduler = AlarmScheduler()

    func deleteAlarm(_ alarm: Alarm, context: ModelContext) {
        scheduler.cancel(alarm)
        context.delete(alarm)
        try? context.save()
    }

    func toggleEnabled(_ alarm: Alarm, context: ModelContext) {
        alarm.isEnabled.toggle()
        try? context.save()
        if alarm.isEnabled { scheduler.schedule(alarm) } else { scheduler.cancel(alarm) }
    }
}
