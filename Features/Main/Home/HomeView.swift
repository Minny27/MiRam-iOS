import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Alarm.hour), SortDescriptor(\Alarm.minute)]) private var alarms: [Alarm]
    @State private var showAddAlarm = false
    @State private var alarmToEdit: Alarm? = nil

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
                    showAddAlarm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddAlarm) {
            AlarmDetailView(mode: .add)
        }
        .sheet(item: $alarmToEdit) { alarm in
            AlarmDetailView(mode: .edit(alarm))
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
                AlarmRowView(alarm: alarm) {
                    viewModel.toggleEnabled(alarm, context: modelContext)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    alarmToEdit = alarm
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteAlarm(alarm, context: modelContext)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void

    private var timeColor: Color { alarm.isEnabled ? .primary : .secondary }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                // 시간 + AM/PM
                HStack(alignment: .bottom, spacing: 6) {
                    Text(alarm.twelveHourTimeString)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundStyle(timeColor)
                    Text(alarm.amPm)
                        .font(.title3.bold())
                        .foregroundStyle(timeColor)
                        .padding(.bottom, 6)
                }

                // 라벨
                Text(alarm.label.isEmpty ? "라벨 없음" : alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(alarm.label.isEmpty ? .tertiary : .secondary)

                // 반복 요일
                if !alarm.repeatDays.isEmpty {
                    Text(alarm.repeatDays.map(\.label).joined(separator: " "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}
