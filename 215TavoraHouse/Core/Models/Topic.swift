import Foundation

enum TopicStatus: String, Codable, CaseIterable {
    case learning
    case known

    var displayName: String {
        switch self {
        case .learning: return "Learning"
        case .known: return "Known"
        }
    }
}

struct Topic: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var status: TopicStatus
    var category: TopicCategory
    var structuredNotes: TopicStructuredNotes
    var lastReviewedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        status: TopicStatus = .learning,
        category: TopicCategory = .general,
        structuredNotes: TopicStructuredNotes? = nil,
        lastReviewedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.status = status
        self.category = category
        self.structuredNotes = structuredNotes ?? TopicStructuredNotes(keyThought: notes)
        self.lastReviewedDate = lastReviewedDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        status = try container.decodeIfPresent(TopicStatus.self, forKey: .status) ?? .learning
        category = try container.decodeIfPresent(TopicCategory.self, forKey: .category) ?? .general
        structuredNotes = try container.decodeIfPresent(TopicStructuredNotes.self, forKey: .structuredNotes)
            ?? TopicStructuredNotes(keyThought: notes)
        lastReviewedDate = try container.decodeIfPresent(Date.self, forKey: .lastReviewedDate)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, notes, status, category, structuredNotes, lastReviewedDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(notes, forKey: .notes)
        try container.encode(status, forKey: .status)
        try container.encode(category, forKey: .category)
        try container.encode(structuredNotes, forKey: .structuredNotes)
        try container.encodeIfPresent(lastReviewedDate, forKey: .lastReviewedDate)
    }
}
