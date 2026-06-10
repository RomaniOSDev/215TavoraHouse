import SwiftUI

// MARK: - Hero Banner

struct HomeHeroWidget: View {
    let greeting: String
    let dateLabel: String
    let streakDays: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(dateLabel)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                if streakDays > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color("AppPrimary"))
                        Text("\(streakDays) day streak")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AppSurface").opacity(0.85))
                    .clipShape(Capsule())
                }
            }
            .padding(16)
        }
        .appHeroCardStyle()
    }
}

// MARK: - Stats Grid

struct HomeStatsGridWidget: View {
    let studyMinutes: Int
    let quizzesCompleted: Int
    let topicsMastered: Int
    let itemsReviewed: Int

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            statTile(value: "\(studyMinutes)", label: "Study Min", icon: "clock.fill")
            statTile(value: "\(quizzesCompleted)", label: "Quizzes", icon: "checkmark.circle.fill")
            statTile(value: "\(topicsMastered)", label: "Mastered", icon: "star.fill")
            statTile(value: "\(itemsReviewed)", label: "Reviewed", icon: "eye.fill")
        }
    }

    private func statTile(value: String, label: String, icon: String) -> some View {
        AppCard(padding: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Quick Action Cards

struct HomeQuickActionWidget: View {
    let onStudy: () -> Void
    let onQuiz: () -> Void
    let onTopics: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Quick Actions", icon: "bolt.fill", tint: Color("AppPrimary"))

            HStack(spacing: 10) {
                actionCard(
                    imageName: "HomeStudy",
                    title: "Study",
                    subtitle: "Start timer",
                    action: onStudy
                )
                actionCard(
                    imageName: "HomeQuiz",
                    title: "Quiz",
                    subtitle: "Practice now",
                    action: onQuiz
                )
            }

            Button(action: onTopics) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                    Text("Browse Topics")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(14)
                .appCardDepth(radius: 12)
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
        }
    }

    private func actionCard(imageName: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.25)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    )

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardDepth()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Due Today

struct HomeDueTodayWidget: View {
    let topics: [Topic]
    let onTopicTap: (Topic) -> Void
    let onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeaderView(
                    title: "Due Today",
                    icon: "clock.badge.exclamationmark",
                    tint: Color("AppAccent")
                )
                Spacer()
                Button("See All", action: onSeeAll)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppPrimary"))
            }

            if topics.isEmpty {
                AppCard {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(Color("AppPrimary"))
                        Text("You're all caught up!")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(topics.prefix(6)) { topic in
                            Button {
                                FeedbackService.lightTap()
                                onTopicTap(topic)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: topic.category.systemImage)
                                        .font(.title2)
                                        .foregroundStyle(Color("AppPrimary"))
                                    Text(topic.title)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Text("Review")
                                        .font(.caption2.bold())
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .padding(14)
                                .frame(width: 140, alignment: .leading)
                                .appCardDepth(accentBorder: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Continue Learning

struct HomeContinueWidget: View {
    let topic: Topic?
    let progress: Double
    let onContinue: () -> Void

    var body: some View {
        if let topic {
            AppCard(accentBorder: true) {
                HStack(spacing: 14) {
                    Image(systemName: topic.category.systemImage)
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                        .appIconPlate(size: 52, highlighted: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Continue Learning")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                        Text(topic.title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color("AppBackground").opacity(0.5))
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
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
                        .frame(height: 6)
                    }

                    Button(action: onContinue) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }
}

// MARK: - Activity & Achievements Row

struct HomeActivityRowWidget: View {
    let activeDaysThisWeek: Int
    let achievementsUnlocked: Int
    let totalAchievements: Int
    let onProgressTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onProgressTap) {
                AppCard(padding: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color("AppPrimary"))
                        Text("\(activeDaysThisWeek)")
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Active days this week")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)

            Button(action: onProgressTap) {
                AppCard(padding: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Color("AppAccent"))
                        Text("\(achievementsUnlocked)/\(totalAchievements)")
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Achievements unlocked")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Focus Areas Mini

struct HomeFocusWidget: View {
    let areas: [FocusArea]
    let onPractice: () -> Void

    var body: some View {
        if !areas.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(title: "Focus Areas", icon: "target", tint: Color("AppAccent"))
                ForEach(areas.prefix(3)) { area in
                    FocusAreaCell(area: area)
                }
                Button(action: onPractice) {
                    Text("Practice Weak Topics")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Latest Reflection

struct HomeReflectionWidget: View {
    let entry: ReflectionEntry?
    let topicTitle: String?
    let onJournalTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeaderView(title: "Latest Reflection", icon: "text.quote")
                Spacer()
                if entry != nil {
                    Button("Journal", action: onJournalTap)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
            }

            if let entry {
                ReflectionCell(entry: entry, topicTitle: topicTitle)
            } else {
                AppCard {
                    Text("Complete a study session to capture what you learned.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
