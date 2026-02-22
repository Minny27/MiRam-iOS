import Foundation
import SwiftData

@MainActor
final class DIContainer {
    static let shared = DIContainer()

    let modelContainer: ModelContainer
    let alarmScheduler: AlarmScheduler
    let alarmRepository: AlarmRepository

    private init() {
        do {
            modelContainer = try ModelContainer(for: Alarm.self)
        } catch {
            fatalError("SwiftData ModelContainer 생성 실패: \(error)")
        }
        alarmScheduler = AlarmScheduler()
        alarmRepository = AlarmRepository(
            modelContext: modelContainer.mainContext,
            scheduler: alarmScheduler
        )
    }
}
