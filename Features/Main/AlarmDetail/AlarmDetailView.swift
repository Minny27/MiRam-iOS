import SwiftUI
import SwiftData

struct AlarmDetailView: View {
    let mode: AlarmDetailMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: AlarmDetailViewModel

    init(mode: AlarmDetailMode) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: AlarmDetailViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section { timePicker }

                Section("라벨") {
                    TextField("알람 이름 (선택)", text: $viewModel.label)
                }

                Section("반복") { weekdayPicker }

                Section("알람 소리") { soundPicker }

                Section("울림 시간") { ringDurationPicker }
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
                            try viewModel.save(context: modelContext)
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

    // MARK: - 시간 피커

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

    // MARK: - 요일 피커

    private var weekdayPicker: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { weekday in
                let selected = viewModel.selectedDays.contains(weekday)
                Button {
                    if selected { viewModel.selectedDays.remove(weekday) }
                    else { viewModel.selectedDays.insert(weekday) }
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

    // MARK: - 사운드 피커

    private var soundPicker: some View {
        
        ForEach(AlarmSound.all) { sound in
            HStack {
                Text(sound.displayName)
                Spacer()
                if viewModel.soundName == sound.id {
                    Image(systemName: "checkmark")
//                        .foregroundStyle(.accentColor)
                }
                Button {
                    sound.playOnce()
                } label: {
                    Image(systemName: "play.circle")
//                        .foregroundStyle(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.soundName = sound.id
            }
        }
    }

    // MARK: - 울림 시간 피커

    private var ringDurationPicker: some View {
        Picker("울림 시간", selection: $viewModel.ringDuration) {
            ForEach(RingDuration.allValues, id: \.self) { sec in
                Text(RingDuration.label(for: sec)).tag(sec)
            }
        }
        .pickerStyle(.navigationLink)
    }
}
