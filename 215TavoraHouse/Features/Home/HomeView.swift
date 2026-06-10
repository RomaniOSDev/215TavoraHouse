import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: AppTab
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTopicForDetail: Topic?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    LazyVStack(spacing: 18) {
                        HomeHeroWidget(
                            greeting: viewModel.greeting(),
                            dateLabel: viewModel.formattedDate(),
                            streakDays: store.streakDays
                        )

                        HomeStatsGridWidget(
                            studyMinutes: store.studyMinutes,
                            quizzesCompleted: store.quizzesCompleted,
                            topicsMastered: store.topicsCompleted,
                            itemsReviewed: store.cardsReviewed
                        )

                        HomeQuickActionWidget(
                            onStudy: { navigate(to: .practice) },
                            onQuiz: { navigate(to: .practice) },
                            onTopics: { navigate(to: .topics) }
                        )

                        HomeContinueWidget(
                            topic: viewModel.continueTopic(from: store),
                            progress: continueProgress,
                            onContinue: {
                                FeedbackService.lightTap()
                                if let topic = viewModel.continueTopic(from: store) {
                                    store.lastViewedTopicId = topic.id
                                    selectedTopicForDetail = topic
                                } else {
                                    navigate(to: .topics)
                                }
                            }
                        )

                        HomeDueTodayWidget(
                            topics: store.topicsDueForReview(),
                            onTopicTap: { topic in
                                selectedTopicForDetail = topic
                            },
                            onSeeAll: { navigate(to: .topics) }
                        )

                        HomeActivityRowWidget(
                            activeDaysThisWeek: viewModel.weeklyActivityCount(from: store),
                            achievementsUnlocked: viewModel.unlockedAchievementsCount(from: store),
                            totalAchievements: Achievement.all.count,
                            onProgressTap: { navigate(to: .progress) }
                        )

                        HomeFocusWidget(
                            areas: store.focusAreas(),
                            onPractice: { navigate(to: .practice) }
                        )

                        HomeReflectionWidget(
                            entry: store.reflectionEntries.first,
                            topicTitle: store.reflectionEntries.first.flatMap {
                                store.topicTitle(for: $0.topicId)
                            },
                            onJournalTap: { navigate(to: .practice) }
                        )

                        Spacer(minLength: 16)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Home")
            
            //.toolbarBackground(Color("AppBackground"), for: .navigationBar)
            //.toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedTopicForDetail) { topic in
                NavigationStack {
                    TopicDetailView(topic: topic)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    FeedbackService.lightTap()
                                    selectedTopicForDetail = nil
                                }
                                .foregroundStyle(Color("AppPrimary"))
                            }
                        }
                }
            }
        }
    }

    private var continueProgress: Double {
        guard let topic = viewModel.continueTopic(from: store) else { return 0 }
        return store.topicProgress[topic.id.uuidString] ?? 0
    }

    private func navigate(to tab: AppTab) {
        FeedbackService.lightTap()
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTab = tab
        }
    }
}
