import Combine
import Foundation
import SwiftUI

final class LearningSummaryViewModel: ObservableObject {
    @Published var segment = 0
    @Published var expandedTopicIds: Set<String> = []
    @Published var showAddBookmarkSheet = false
    @Published var bookmarkTitle = ""
    @Published var bookmarkSearchText = ""
    @Published var bookmarkError: String?
    @Published var shakeBookmark = false
    @Published var pulsingTopicId: String?
    @Published var showSuccessBadge = false

    @Published var studySeconds: Int = 0
    @Published var isTimerRunning = false
    @Published var showReflectionSheet = false
    @Published var reflectionText = ""

    private var timerCancellable: AnyCancellable?
    private var scenePhase: ScenePhase = .active
    private var pendingSessionMinutes = 0

    func updateScenePhase(_ phase: ScenePhase) {
        scenePhase = phase
        if phase != .active {
            pauseTimer()
        }
    }

    func toggleExpanded(_ topicId: String) {
        FeedbackService.lightTap()
        if expandedTopicIds.contains(topicId) {
            expandedTopicIds.remove(topicId)
        } else {
            expandedTopicIds.insert(topicId)
        }
    }

    func addBookmark(store: AppDataStore) -> Bool {
        let trimmed = bookmarkTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            bookmarkError = "Please enter a bookmark title."
            shakeBookmark = true
            FeedbackService.warning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.shakeBookmark = false }
            return false
        }
        store.addBookmark(trimmed)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        FeedbackService.bookmarkSound()
        FeedbackService.success()
        bookmarkTitle = ""
        bookmarkError = nil
        showAddBookmarkSheet = false
        return true
    }

    func pulseTopic(_ id: String) {
        pulsingTopicId = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulsingTopicId = nil
        }
    }

    func startTimer(store: AppDataStore) {
        guard scenePhase == .active else { return }
        isTimerRunning = true
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isTimerRunning, self.scenePhase == .active else { return }
                self.studySeconds += 1
                if store.sessionPlan.goalType == .minutes,
                   self.studySeconds >= store.sessionPlan.goalValue * 60 {
                    FeedbackService.success()
                }
            }
    }

    func pauseTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func commitStudyTime(store: AppDataStore) {
        let minutes = max(studySeconds / 60, studySeconds > 0 ? 1 : 0)
        guard minutes > 0 else {
            studySeconds = 0
            pauseTimer()
            return
        }
        pendingSessionMinutes = minutes
        store.completeSession(minutesStudied: minutes)
        studySeconds = 0
        pauseTimer()
        showReflectionSheet = true
    }

    func saveReflection(store: AppDataStore) {
        let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackService.warning()
            return
        }
        store.addReflection(text: trimmed, topicId: store.sessionPlan.topicId)
        FeedbackService.mediumTap()
        FeedbackService.success()
        reflectionText = ""
        showReflectionSheet = false
    }

    func skipReflection() {
        FeedbackService.lightTap()
        reflectionText = ""
        showReflectionSheet = false
    }

    func sessionGoalProgress(store: AppDataStore) -> Double {
        switch store.sessionPlan.goalType {
        case .minutes:
            guard store.sessionPlan.goalValue > 0 else { return 0 }
            return min(Double(studySeconds) / Double(store.sessionPlan.goalValue * 60), 1.0)
        case .quizCount:
            guard store.sessionPlan.goalValue > 0 else { return 0 }
            return min(Double(store.sessionPlan.quizzesCompletedInSession) / Double(store.sessionPlan.goalValue), 1.0)
        }
    }

    func sessionGoalLabel(store: AppDataStore) -> String {
        switch store.sessionPlan.goalType {
        case .minutes:
            return "\(studySeconds / 60)/\(store.sessionPlan.goalValue) min"
        case .quizCount:
            return "\(store.sessionPlan.quizzesCompletedInSession)/\(store.sessionPlan.goalValue) quizzes"
        }
    }

    func weeklyTime(for topicTitle: String, store: AppDataStore) -> TimeInterval {
        let stats = store.weeklyStats[topicTitle] ?? [:]
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return stats.reduce(0) { result, pair in
            guard let date = AppDataStore.date(from: pair.key), date >= weekAgo else { return result }
            return result + pair.value
        }
    }

    func comprehensionScore(for topic: Topic, store: AppDataStore) -> Int {
        let progress = store.topicProgress[topic.id.uuidString] ?? 0
        return Int(progress * 100)
    }

    func filteredBookmarks(from store: AppDataStore) -> [String] {
        store.filteredBookmarks(search: bookmarkSearchText)
    }
}
