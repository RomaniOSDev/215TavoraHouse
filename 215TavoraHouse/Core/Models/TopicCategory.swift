import Foundation

enum TopicCategory: String, Codable, CaseIterable, Identifiable {
    case math
    case language
    case work
    case general

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .math: return "Math"
        case .language: return "Language"
        case .work: return "Work"
        case .general: return "General"
        }
    }

    var systemImage: String {
        switch self {
        case .math: return "function"
        case .language: return "text.book.closed"
        case .work: return "briefcase.fill"
        case .general: return "folder.fill"
        }
    }
}
