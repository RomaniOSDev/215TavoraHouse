import SwiftUI

struct QuizQuestionCell: View {
    let question: QuizQuestion
    let topicTitle: String?
    let state: QuizAnswerState
    let onSelectOption: (Int) -> Void
    let onSubmit: () -> Void

    var body: some View {
        AppCard(accentBorder: state.isSubmitted && state.isCorrect) {
            VStack(alignment: .leading, spacing: 14) {
                headerRow
                optionsSection
                footerSection
            }
        }
    }

    private var headerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let topicTitle {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.caption2)
                    Text(topicTitle)
                        .font(.caption.bold())
                }
                .foregroundStyle(Color("AppAccent"))
            }

            Text(question.question)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var optionsSection: some View {
        VStack(spacing: 8) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                optionButton(option: option, index: index)
            }
        }
    }

    private func optionButton(option: String, index: Int) -> some View {
        let isSelected = state.selectedIndex == index
        let showResult = state.isSubmitted
        let isCorrectOption = index == question.correctIndex

        return Button {
            guard !state.isSubmitted else { return }
            onSelectOption(index)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected && !showResult {
                        Circle()
                            .fill(Color("AppPrimary"))
                            .frame(width: 12, height: 12)
                    }
                }

                Text(option)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.leading)

                Spacer()

                if showResult {
                    if isCorrectOption {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(optionBackground(isSelected: isSelected, isCorrect: isCorrectOption, showResult: showResult))
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .disabled(state.isSubmitted)
    }

    private func optionBackground(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult && isCorrect { return Color("AppPrimary").opacity(0.15) }
        if showResult && isSelected && !isCorrect { return Color.red.opacity(0.12) }
        if isSelected { return Color("AppAccent").opacity(0.15) }
        return Color("AppBackground").opacity(0.35)
    }

    @ViewBuilder
    private var footerSection: some View {
        if state.selectedIndex != nil, !state.isSubmitted {
            Button(action: onSubmit) {
                Text("Submit Answer")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppPrimaryFill())
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color("AppTextPrimary").opacity(0.15), lineWidth: 1)
                    )
                    .compositingGroup()
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
        }

        if state.isSubmitted {
            HStack {
                Image(systemName: state.isCorrect ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(state.isCorrect ? Color("AppPrimary") : Color("AppAccent"))
                Text(state.isCorrect ? "Correct answer" : "Keep practicing")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Text("\(state.isCorrect ? 100 : 0)%")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(.top, 4)
        }
    }
}
