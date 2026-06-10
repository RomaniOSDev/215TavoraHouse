import Foundation

struct QuizQuestion: Codable, Identifiable, Equatable {
    let id: UUID
    var topicId: UUID?
    var question: String
    var options: [String]
    var correctIndex: Int
    var isSample: Bool

    init(
        id: UUID = UUID(),
        topicId: UUID? = nil,
        question: String,
        options: [String],
        correctIndex: Int,
        isSample: Bool = false
    ) {
        self.id = id
        self.topicId = topicId
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.isSample = isSample
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        topicId = try container.decodeIfPresent(UUID.self, forKey: .topicId)
        question = try container.decode(String.self, forKey: .question)
        options = try container.decode([String].self, forKey: .options)
        correctIndex = try container.decode(Int.self, forKey: .correctIndex)
        isSample = try container.decodeIfPresent(Bool.self, forKey: .isSample) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case id, topicId, question, options, correctIndex, isSample
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(topicId, forKey: .topicId)
        try container.encode(question, forKey: .question)
        try container.encode(options, forKey: .options)
        try container.encode(correctIndex, forKey: .correctIndex)
        try container.encode(isSample, forKey: .isSample)
    }

    static let defaultSamples: [QuizQuestion] = SeedData.quizQuestions
}

struct QuizAnswerState: Codable, Equatable {
    var selectedIndex: Int?
    var isSubmitted: Bool
    var isCorrect: Bool

    init(selectedIndex: Int? = nil, isSubmitted: Bool = false, isCorrect: Bool = false) {
        self.selectedIndex = selectedIndex
        self.isSubmitted = isSubmitted
        self.isCorrect = isCorrect
    }
}
