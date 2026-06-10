import SwiftUI

struct TopicCell: View {
    let topic: Topic
    var progress: Double = 0
    var showsCheckmark: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: topic.category.systemImage)
                .font(.system(size: 20))
                .foregroundStyle(categoryColor)
                .appIconPlate(size: 48, highlighted: true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)

                    Text(topic.category.displayName)
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color("AppAccent").opacity(0.35),
                                    Color("AppAccent").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                }

                if !topic.structuredNotes.keyThought.isEmpty {
                    Text(topic.structuredNotes.keyThought)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    statusBadge
                    if progress > 0 {
                        Text("\(Int(progress * 100))%")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
            }

            Spacer(minLength: 4)

            if showsCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch topic.category {
        case .math: return Color("AppPrimary")
        case .language: return Color("AppAccent")
        case .work: return Color("AppTextPrimary")
        case .general: return Color("AppTextSecondary")
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(topic.status == .known ? Color("AppPrimary") : Color("AppAccent"))
                .frame(width: 6, height: 6)
            Text(topic.status.displayName)
                .font(.caption.bold())
                .foregroundStyle(topic.status == .known ? Color("AppPrimary") : Color("AppAccent"))
        }
    }
}

struct DueTodayCell: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "clock.badge.exclamationmark")
                .foregroundStyle(Color("AppAccent"))
                .appIconPlate(size: 44, highlighted: true)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Time to review")
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("AppPrimary"))
        }
    }
}
