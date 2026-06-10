import SwiftUI

struct ProgressTopicCell: View {
    let topic: Topic
    let progress: Double
    let isExpanded: Bool
    let weeklyTimeLabel: String
    let comprehensionPercent: Int
    let isPulsing: Bool
    let onToggle: () -> Void

    var body: some View {
        AppCard(accentBorder: isPulsing) {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: onToggle) {
                    HStack(spacing: 12) {
                        Image(systemName: topic.category.systemImage)
                            .foregroundStyle(Color("AppPrimary"))
                            .appIconPlate(size: 40, highlighted: true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.title)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("\(Int(progress * 100))% learned")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color("AppBackground").opacity(0.5))
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppAccent"), Color("AppPrimary")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 8)

                if isExpanded {
                    VStack(spacing: 8) {
                        detailRow(label: "Time this week", value: weeklyTimeLabel)
                        detailRow(label: "Comprehension", value: "\(comprehensionPercent)%")
                        detailRow(label: "Category", value: topic.category.displayName)
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}

struct ReflectionCell: View {
    let entry: ReflectionEntry
    let topicTitle: String?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundStyle(Color("AppPrimary"))
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    if let topicTitle {
                        Text(topicTitle)
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color("AppAccent").opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(entry.text)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var formattedDate: String {
        AppDataStore.displayDate(entry.date)
    }
}

struct BookmarkCell: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bookmark.fill")
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
        }
        .padding(14)
        .appCardDepth()
    }
}

struct FocusAreaCell: View {
    let area: FocusArea

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "target")
                .foregroundStyle(Color("AppAccent"))
                .appIconPlate(size: 40, highlighted: true)

            VStack(alignment: .leading, spacing: 2) {
                Text(area.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(area.totalAnswered) answered")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            Text("\(area.correctPercent)%")
                .font(.title3.bold())
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(14)
        .appCardDepth()
    }
}
