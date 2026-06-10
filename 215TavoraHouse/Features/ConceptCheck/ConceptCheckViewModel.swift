import Combine
import Foundation

final class ConceptCheckViewModel: ObservableObject {
    @Published var showEditSheet = false
    @Published var showSummarySheet = false
    @Published var selectedTopicId: UUID?
    @Published var searchText = ""
    @Published var newQuestion = ""
    @Published var newOptions: [String] = ["", "", "", ""]
    @Published var newQuestionTopicId: UUID?
    @Published var correctOptionIndex = 0
    @Published var questionError: String?
    @Published var shakeQuestion = false

    func submitAnswer(for question: QuizQuestion, store: AppDataStore) {
        guard let state = store.quizAnswerStates[question.id.uuidString],
              let selected = state.selectedIndex,
              !state.isSubmitted else { return }

        let isCorrect = store.submitQuizAnswer(questionId: question.id, selectedIndex: selected)
        FeedbackService.mediumTap()
        FeedbackService.vibrate()
        if isCorrect {
            FeedbackService.success()
        }
    }

    func answerState(for questionId: UUID, store: AppDataStore) -> QuizAnswerState {
        store.quizAnswerStates[questionId.uuidString] ?? QuizAnswerState()
    }

    func filteredQuestions(from store: AppDataStore) -> [QuizQuestion] {
        store.filteredQuestions(search: searchText, topicId: selectedTopicId)
    }

    func addQuestion(store: AppDataStore) -> Bool {
        let trimmed = newQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        let filledOptions = newOptions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard !trimmed.isEmpty else {
            questionError = "Please enter a question."
            shakeQuestion = true
            FeedbackService.warning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.shakeQuestion = false }
            return false
        }

        guard filledOptions.allSatisfy({ !$0.isEmpty }) else {
            questionError = "Please fill all four options."
            shakeQuestion = true
            FeedbackService.warning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.shakeQuestion = false }
            return false
        }

        store.addQuizQuestion(
            question: trimmed,
            options: filledOptions,
            correctIndex: correctOptionIndex,
            topicId: newQuestionTopicId
        )
        FeedbackService.mediumTap()
        FeedbackService.success()
        resetForm()
        showEditSheet = false
        return true
    }

    func resetForm() {
        newQuestion = ""
        newOptions = ["", "", "", ""]
        newQuestionTopicId = nil
        correctOptionIndex = 0
        questionError = nil
    }

    func averageScore(from store: AppDataStore) -> Int {
        guard !store.userScores.isEmpty else { return 0 }
        return store.userScores.reduce(0, +) / store.userScores.count
    }
}
