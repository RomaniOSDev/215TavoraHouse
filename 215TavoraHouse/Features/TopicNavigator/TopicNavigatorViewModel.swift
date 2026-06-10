import Combine
import Foundation

final class TopicNavigatorViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var topicName = ""
    @Published var topicNotes = ""
    @Published var selectedCategory: TopicCategory = .general
    @Published var searchText = ""
    @Published var filterCategory: TopicCategory?
    @Published var nameError: String?
    @Published var shakeName = false
    @Published var animatingKnownIds: Set<UUID> = []
    @Published var showSuccessBadge = false

    func validateAndSave(using store: AppDataStore) -> Bool {
        let trimmed = topicName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            nameError = "Please enter a topic name."
            shakeName = true
            FeedbackService.warning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.shakeName = false
            }
            return false
        }
        store.addTopic(title: trimmed, notes: topicNotes, category: selectedCategory)
        FeedbackService.mediumTap()
        FeedbackService.success()
        topicName = ""
        topicNotes = ""
        selectedCategory = .general
        nameError = nil
        showAddSheet = false
        return true
    }

    func markKnown(_ topic: Topic, store: AppDataStore) {
        store.markTopic(topic, status: .known)
        animatingKnownIds.insert(topic.id)
        FeedbackService.softTap()
        FeedbackService.vibrate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animatingKnownIds.remove(topic.id)
        }
    }

    func markLearning(_ topic: Topic, store: AppDataStore) {
        store.markTopic(topic, status: .learning)
        FeedbackService.lightTap()
    }

    func filteredTopics(from store: AppDataStore) -> [Topic] {
        store.filteredTopics(search: searchText, category: filterCategory)
    }
}
