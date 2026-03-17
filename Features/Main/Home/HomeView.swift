import SwiftUI
import SwiftData

private enum AlarmSheet: Identifiable {
    case add
    case edit(Alarm)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let alarm): return alarm.id.uuidString
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Alarm.hour), SortDescriptor(\Alarm.minute)]) private var alarms: [Alarm]
    @State private var activeSheet: AlarmSheet? = nil

    var body: some View {
        Group {
            if alarms.isEmpty {
                emptyState
            } else {
                alarmList
            }
        }
        .navigationTitle("알람")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                AlarmDetailView(mode: .add)
            case .edit(let alarm):
                AlarmDetailView(mode: .edit(alarm))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "alarm")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("알람이 없습니다")
                .foregroundStyle(.secondary)
        }
    }

    private var alarmList: some View {
        List {
            ForEach(alarms) { alarm in
                AlarmRowView(
                    alarm: alarm,
                    onToggle: { viewModel.toggleEnabled(alarm, context: modelContext) },
                    onTap:   { activeSheet = .edit(alarm) },
                    onDelete: { viewModel.deleteAlarm(alarm, context: modelContext) }
                )
            }
        }
        .listStyle(.plain)
    }
}

private struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 시간 + AM/PM + 라벨 + 요일
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(alarm.twelveHourTimeString)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(alarm.isEnabled ? Color.primary : Color.secondary)
                    Text(alarm.amPm)
                        .font(.title3.bold())
                        .foregroundStyle(alarm.isEnabled ? Color.primary : Color.secondary)
                }

                Text(alarm.label.isEmpty ? String(localized: "알람") : alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(alarm.label.isEmpty ? Color.secondary : Color.white)

                if !alarm.repeatDays.isEmpty {
                    Text(alarm.repeatDays.map(\.label).joined(separator: " "))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}
