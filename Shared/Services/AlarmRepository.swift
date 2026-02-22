import Foundation
import SwiftData

@MainActor
final class AlarmRepository {
    private let modelContext: ModelContext
    private let scheduler: AlarmScheduler

    init(modelContext: ModelContext, scheduler: AlarmScheduler) {
        self.modelContext = modelContext
        self.scheduler = scheduler
    }

    func fetchAll() throws -> [Alarm] {
        let descriptor = FetchDescriptor<Alarm>(
            sortBy: [SortDescriptor(\.hour), SortDescriptor(\.minute)]
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ alarm: Alarm) throws {
        modelContext.insert(alarm)
        try modelContext.save()
        if alarm.isEnabled {
            scheduler.schedule(alarm)
        }
    }

    func update(_ alarm: Alarm) throws {
        try modelContext.save()
        scheduler.cancel(alarm)
        if alarm.isEnabled {
            scheduler.schedule(alarm)
        }
    }

    func delete(_ alarm: Alarm) throws {
        scheduler.cancel(alarm)
        modelContext.delete(alarm)
        try modelContext.save()
    }

    func setEnabled(_ alarm: Alarm, enabled: Bool) throws {
        alarm.isEnabled = enabled
        try modelContext.save()
        if enabled {
            scheduler.schedule(alarm)
        } else {
            scheduler.cancel(alarm)
        }
    }
}
