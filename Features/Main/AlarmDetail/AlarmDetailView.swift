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
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        timePickerCard
                        repeatCard
                        soundCard
                        ringDurationCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .tint(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        Task {
                            do {
                                try await viewModel.save(context: modelContext)
                                dismiss()
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .tint(.orange)
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

    private var timePickerCard: some View {
        VStack(spacing: 20) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(viewModel.amPm)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(viewModel.timePreview)
                    .font(.system(size: 54, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 8) {
                Picker("시", selection: $viewModel.hour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Text(":")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Picker("분", selection: $viewModel.minute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 180)
        }
        .padding(24)
        .background(cardBackground)
    }

    private var repeatCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("반복")
            weekdayPicker

            VStack(alignment: .leading, spacing: 10) {
                Text("라벨")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                TextField("알람 이름", text: $viewModel.label)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private var weekdayPicker: some View {
        HStack(spacing: 10) {
            ForEach(Weekday.allCases) { weekday in
                let isSelected = viewModel.selectedDays.contains(weekday)

                Button {
                    if isSelected {
                        viewModel.selectedDays.remove(weekday)
                    } else {
                        viewModel.selectedDays.insert(weekday)
                    }
                } label: {
                    Text(weekday.label)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(isSelected ? Color.orange : Color.white.opacity(0.06))
                        )
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var soundCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("알람 소리")

            VStack(spacing: 0) {
                ForEach(Array(AlarmSound.all.enumerated()), id: \.element.id) { index, sound in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sound.displayName)
                                .foregroundStyle(.white)
                            Text(sound.id == viewModel.soundName ? "현재 선택됨" : "미리 듣기 가능")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if viewModel.soundName == sound.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }

                        Button {
                            sound.playOnce()
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.soundName = sound.id
                    }
                    .padding(.vertical, 14)

                    if index < AlarmSound.all.count - 1 {
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                    }
                }
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private var ringDurationCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("울림 시간")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                ForEach(RingDuration.allValues, id: \.self) { seconds in
                    let isSelected = RingDuration.normalize(viewModel.ringDuration) == seconds

                    Button {
                        viewModel.ringDuration = seconds
                    } label: {
                        Text(RingDuration.label(for: seconds))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(isSelected ? Color.orange : Color.white.opacity(0.06))
                            )
                            .foregroundStyle(isSelected ? .white : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.08))
    }
}
