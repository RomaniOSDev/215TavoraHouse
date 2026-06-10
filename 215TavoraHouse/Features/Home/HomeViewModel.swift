import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    func greeting(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    func formattedDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    func continueTopic(from store: AppDataStore) -> Topic? {
        if let id = store.lastViewedTopicId {
            return store.topics.first(where: { $0.id == id })
        }
        return store.topics.first
    }

    func weeklyActivityCount(from store: AppDataStore) -> Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        return store.activityDates.filter { key in
            guard let date = AppDataStore.date(from: key) else { return false }
            return date >= weekAgo
        }.count
    }

    func unlockedAchievementsCount(from store: AppDataStore) -> Int {
        Achievement.all.filter { achievement in
            achievement.isUnlocked(
                cardsReviewed: store.cardsReviewed,
                quizzesCompleted: store.quizzesCompleted,
                topicsCompleted: store.topicsCompleted,
                studyMinutes: store.studyMinutes,
                streakDays: store.streakDays
            )
        }.count
    }
}
