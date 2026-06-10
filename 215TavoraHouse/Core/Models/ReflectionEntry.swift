import Foundation

struct ReflectionEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var text: String
    var topicId: UUID?

    init(id: UUID = UUID(), date: Date = Date(), text: String, topicId: UUID? = nil) {
        self.id = id
        self.date = date
        self.text = text
        self.topicId = topicId
    }
}
