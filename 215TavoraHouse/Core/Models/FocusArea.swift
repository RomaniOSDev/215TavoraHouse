import Foundation

struct FocusArea: Identifiable, Equatable {
    let id: String
    let title: String
    let correctPercent: Int
    let totalAnswered: Int
}
