import SwiftUI

struct StatsAchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        ActivityCalendarView(activeDayKeys: Set(store.activityDates))
                        achievementsGrid
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var summaryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(title: "Summary", icon: "chart.bar.fill")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricStatCell(value: "\(store.cardsReviewed)", label: "Reviewed", icon: "eye.fill")
                    MetricStatCell(value: "\(store.studyMinutes)", label: "Minutes", icon: "clock.fill")
                    MetricStatCell(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }

                VStack(spacing: 8) {
                    SummaryMetricRow(label: "Quizzes Completed", value: "\(store.quizzesCompleted)", icon: "checkmark.circle")
                    Divider().background(Color("AppTextSecondary").opacity(0.2))
                    SummaryMetricRow(label: "Topics Mastered", value: "\(store.topicsCompleted)", icon: "star.fill")
                    Divider().background(Color("AppTextSecondary").opacity(0.2))
                    SummaryMetricRow(label: "Due for Review", value: "\(store.dueTodayCount)", icon: "clock.badge.exclamationmark")
                }
            }
        }
    }

    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Achievements", icon: "trophy.fill", tint: Color("AppPrimary"))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Achievement.all) { achievement in
                    AchievementCell(
                        achievement: achievement,
                        isUnlocked: achievement.isUnlocked(
                            cardsReviewed: store.cardsReviewed,
                            quizzesCompleted: store.quizzesCompleted,
                            topicsCompleted: store.topicsCompleted,
                            studyMinutes: store.studyMinutes,
                            streakDays: store.streakDays
                        )
                    )
                }
            }
        }
    }
}
