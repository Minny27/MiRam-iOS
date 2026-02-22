import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddAlarm = false

    var body: some View {
        Group {
            if viewModel.alarms.isEmpty {
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
        .sheet(isPresented: $showAddAlarm, onDismiss: { viewModel.loadAlarms() }) {
            AlarmDetailView(mode: .add)
        }
        .onAppear { viewModel.loadAlarms() }
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
            ForEach(viewModel.alarms) { alarm in
                AlarmRowView(alarm: alarm) {
                    viewModel.toggleEnabled(alarm)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // navigate to detail handled via NavigationLink in parent
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteAlarm(alarm)
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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 40, weight: .thin, design: .monospaced))
                    .foregroundStyle(alarm.isEnabled ? .primary : .secondary)
                if !alarm.label.isEmpty {
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
