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

private struct AlarmHeaderMaxYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct SafeAreaTopInsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Alarm.hour), SortDescriptor(\Alarm.minute)]) private var alarms: [Alarm]
    @State private var activeSheet: AlarmSheet? = nil
    @State private var alarmHeaderMaxY: CGFloat = .greatestFiniteMagnitude
    @State private var safeAreaTopInset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                List {
                    Section {
                        summaryCard
                            .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        if viewModel.authorizationDenied {
                            authorizationCard
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }

                    Section {
                        if alarms.isEmpty {
                            emptyState
                                .listRowInsets(EdgeInsets(top: 48, leading: 0, bottom: 0, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(alarms) { alarm in
                                AlarmRowView(
                                    alarm: alarm,
                                    onToggle: {
                                        Task { await viewModel.toggleEnabled(alarm, context: modelContext) }
                                    },
                                    onTap: { activeSheet = .edit(alarm) },
                                    onDelete: { viewModel.deleteAlarm(alarm, context: modelContext) }
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        Text("알람")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .textCase(nil)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: AlarmHeaderMaxYPreferenceKey.self,
                                        value: geometry.frame(in: .global).maxY
                                    )
                                }
                            )
                    }
                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(
                Color.clear.preference(
                    key: SafeAreaTopInsetPreferenceKey.self,
                    value: proxy.safeAreaInsets.top
                )
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onPreferenceChange(AlarmHeaderMaxYPreferenceKey.self) { value in
            alarmHeaderMaxY = value
        }
        .onPreferenceChange(SafeAreaTopInsetPreferenceKey.self) { value in
            safeAreaTopInset = value
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .tint(.orange)
            }

            ToolbarItem(placement: .principal) {
                if shouldShowNavigationTitle(safeAreaTop: safeAreaTopInset) {
                    Text("알람")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                }
                .tint(.orange)
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
        .task {
            viewModel.prepare()
        }
        .alert("알람을 저장할 수 없습니다", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func shouldShowNavigationTitle(safeAreaTop: CGFloat) -> Bool {
        alarmHeaderMaxY <= safeAreaTop + 44
    }

    private var summaryCard: some View {
        let summary = NextAlarmSummary(alarms: alarms)

        return VStack(spacing: 10) {
            Text("다음 알람")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(summary.title)
                .font(.system(size: 34, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(summary.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var authorizationCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell.badge.slash.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("AlarmKit 권한이 꺼져 있습니다")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("설정에서 MiRam의 알람 권한을 허용해야 백그라운드 알람을 예약할 수 있습니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.orange.opacity(0.14))
        )
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "alarm")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("아직 설정한 알람이 없습니다")
                .font(.headline)
                .foregroundStyle(.white)
            Text("오른쪽 위의 + 버튼으로 기본 시계 앱처럼 알람을 추가할 수 있습니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}

private struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(alarm.amPm)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(alarm.isEnabled ? Color.secondary : Color.gray)

                    Text(alarm.twelveHourTimeString)
                        .font(.system(size: 46, weight: .thin, design: .rounded))
                        .foregroundStyle(alarm.isEnabled ? .white : .gray)
                }

                HStack(spacing: 0) {
                    Text(alarm.displayLabel)
                        .font(.footnote)
                        .foregroundStyle(alarm.isEnabled ? .white : .gray)

                    if !alarm.repeatDayRaws.isEmpty {
                        Text(", \(alarm.repeatDescription)")
                            .font(.footnote)
                            .foregroundStyle(alarm.isEnabled ? .white : .gray)
                    }
                }
                
                Text(alarm.ringDurationLabel)
                    .font(.footnote)
                    .foregroundStyle(alarm.isEnabled ? .white : .gray)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: .orange))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(alarm.isEnabled ? 0.08 : 0.04))
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

private struct NextAlarmSummary {
    let title: String
    let subtitle: String

    init(alarms: [Alarm]) {
        let enabledAlarms = alarms.filter(\.isEnabled)
        guard
            let nextAlarm = enabledAlarms.min(by: { $0.nextTriggerDate() < $1.nextTriggerDate() })
        else {
            title = "설정된 알람이 없습니다"
            subtitle = "알람을 추가하면 다음 울림 시간이 여기에 표시됩니다."
            return
        }

        let nextDate = nextAlarm.nextTriggerDate()
        title = Self.relativeDescription(until: nextDate)
        subtitle = "\(Self.dateFormatter.string(from: nextDate)) · \(nextAlarm.displayLabel)"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE a h:mm"
        return formatter
    }()

    private static func relativeDescription(until date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: date)
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = max(1, components.minute ?? 0)

        if day > 0 {
            return "\(day)일 \(hour)시간 후"
        }
        if hour > 0 {
            return "\(hour)시간 \(minute)분 후"
        }
        return "\(minute)분 후"
    }
}
