import SwiftUI

struct AlarmDetailView: View {
    let mode: AlarmDetailMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AlarmDetailViewModel

    init(mode: AlarmDetailMode) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: AlarmDetailViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 시간 선택
                Section {
                    timePicker
                }

                // 라벨
                Section("라벨") {
                    TextField("알람 이름 (선택)", text: $viewModel.label)
                }

                // 반복 요일
                Section("반복") {
                    weekdayPicker
                }

                // Ring Duration
                Section("울림 시간") {
                    ringDurationPicker
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        do {
                            try viewModel.save()
                            dismiss()
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .add: return "알람 추가"
        case .edit: return "알람 편집"
        }
    }

    private var timePicker: some View {
        HStack {
            Spacer()
            Picker("시", selection: $viewModel.hour) {
                ForEach(0..<24, id: \.self) { h in
                    Text(String(format: "%02d", h)).tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()

            Text(":")
                .font(.title2.bold())

            Picker("분", selection: $viewModel.minute) {
                ForEach(0..<60, id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()
            Spacer()
        }
    }

    private var weekdayPicker: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { weekday in
                let selected = viewModel.selectedDays.contains(weekday)
                Button {
                    if selected {
                        viewModel.selectedDays.remove(weekday)
                    } else {
                        viewModel.selectedDays.insert(weekday)
                    }
                } label: {
                    Text(weekday.label)
                        .font(.caption.bold())
                        .frame(width: 36, height: 36)
                        .background(selected ? Color.accentColor : Color(.systemGray5))
                        .foregroundStyle(selected ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private var ringDurationPicker: some View {
        Picker("울림 시간", selection: $viewModel.ringDuration) {
            ForEach(RingDuration.allValues, id: \.self) { sec in
                Text(RingDuration.label(for: sec)).tag(sec)
            }
        }
        .pickerStyle(.navigationLink)
    }
}
