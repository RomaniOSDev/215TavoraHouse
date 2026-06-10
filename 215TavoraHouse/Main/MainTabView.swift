import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var bannerManager = AchievementBannerManager()

    var body: some View {
        ZStack {
           

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                    case .topics:
                        TopicNavigatorView()
                    case .practice:
                        PracticeContainerView()
                    case .progress:
                        StatsAchievementsView()
                    case .settings:
                        SettingsView()
                    }
                }
                //.frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab, dueReviewCount: store.dueTodayCount)
            }

            if bannerManager.isVisible, let achievement = bannerManager.currentBanner {
                AchievementBannerView(achievement: achievement)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onChange(of: store.newlyUnlockedAchievement?.id) { _ in
            presentAchievementBannerIfNeeded()
        }
        .onChange(of: bannerManager.isVisible) { visible in
            if !visible {
                store.advanceAchievementQueue()
            }
        }
        .onAppear {
            store.checkAchievements()
            presentAchievementBannerIfNeeded()
        }
    }

    private func presentAchievementBannerIfNeeded() {
        guard !bannerManager.isVisible, let achievement = store.consumeNewAchievement() else { return }
        bannerManager.showUnlock(for: achievement)
    }
}

struct PracticeContainerView: View {
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $segment) {
                Text("Concept Check").tag(0)
                Text("Learning Summary").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .onChange(of: segment) { _ in FeedbackService.lightTap() }

            if segment == 0 {
                ConceptCheckView()
            } else {
                LearningSummaryView()
            }
        }
    }
}
