import Foundation

enum SessionGoalType: String, Codable, CaseIterable, Identifiable {
    case minutes
    case quizCount

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minutes: return "Study Time"
        case .quizCount: return "Quiz Questions"
        }
    }
}

struct SessionPlan: Codable, Equatable {
    var topicId: UUID?
    var goalType: SessionGoalType
    var goalValue: Int
    var quizzesCompletedInSession: Int

    init(
        topicId: UUID? = nil,
        goalType: SessionGoalType = .minutes,
        goalValue: Int = 25,
        quizzesCompletedInSession: Int = 0
    ) {
        self.topicId = topicId
        self.goalType = goalType
        self.goalValue = goalValue
        self.quizzesCompletedInSession = quizzesCompletedInSession
    }
}
