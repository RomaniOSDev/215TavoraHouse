import Foundation

struct ChecklistItem: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    var isCompleted: Bool

    init(id: UUID = UUID(), text: String, isCompleted: Bool = false) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
    }
}

struct TopicStructuredNotes: Codable, Equatable {
    var keyThought: String
    var example: String
    var checklist: [ChecklistItem]
    var linkedBookmarks: [String]

    init(
        keyThought: String = "",
        example: String = "",
        checklist: [ChecklistItem] = [],
        linkedBookmarks: [String] = []
    ) {
        self.keyThought = keyThought
        self.example = example
        self.checklist = checklist
        self.linkedBookmarks = linkedBookmarks
    }
}
