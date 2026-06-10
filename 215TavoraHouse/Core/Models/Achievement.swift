import Foundation

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [Achievement] = [
        Achievement(id: "first_steps", title: "First Steps", description: "Reviewed your first card.", systemImage: "star.fill"),
        Achievement(id: "quiz_enthusiast", title: "Quiz Enthusiast", description: "Completed 10 quizzes.", systemImage: "checkmark.circle.fill"),
        Achievement(id: "concept_mastery", title: "Concept Mastery", description: "Mastered 5 topics.", systemImage: "brain.head.profile"),
        Achievement(id: "time_investor", title: "Time Investor", description: "Studied for over 100 minutes.", systemImage: "clock.fill"),
        Achievement(id: "getting_going", title: "Getting Going", description: "Reached 10 items.", systemImage: "arrow.up.circle.fill"),
        Achievement(id: "power_user", title: "Power User", description: "Reached 50 items.", systemImage: "bolt.fill"),
        Achievement(id: "dedicated_user", title: "Dedicated User", description: "Completed 50 sessions.", systemImage: "flame.fill"),
        Achievement(id: "three_day_streak", title: "Three-Day Streak", description: "Used the app 3 days in a row.", systemImage: "calendar")
    ]

    func isUnlocked(cardsReviewed: Int, quizzesCompleted: Int, topicsCompleted: Int, studyMinutes: Int, streakDays: Int) -> Bool {
        switch id {
        case "first_steps": return cardsReviewed >= 1
        case "quiz_enthusiast": return quizzesCompleted >= 10
        case "concept_mastery": return topicsCompleted >= 5
        case "time_investor": return studyMinutes >= 100
        case "getting_going": return cardsReviewed >= 10
        case "power_user": return cardsReviewed >= 50
        case "dedicated_user": return quizzesCompleted >= 50
        case "three_day_streak": return streakDays >= 3
        default: return false
        }
    }
}
