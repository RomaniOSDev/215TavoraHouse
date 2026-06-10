import Combine
import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    let pages: [(headline: String, description: String, illustration: OnboardingIllustration)] = [
        (
            "Learn Efficiently",
            "Discover how to enhance your understanding through structured content.",
            .books
        ),
        (
            "Capture Ideas",
            "Create interactive digital notes to link concepts together effortlessly.",
            .notes
        ),
        (
            "Begin Exploring",
            "Start by setting up your first study topic today.",
            .explore
        )
    ]

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var buttonTitle: String {
        isLastPage ? "Get Started" : "Next"
    }

    var progress: CGFloat {
        CGFloat(currentPage + 1) / CGFloat(pages.count)
    }

    func nextPage(onComplete: () -> Void) {
        FeedbackService.lightTap()
        if isLastPage {
            FeedbackService.mediumTap()
            FeedbackService.success()
            onComplete()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }
}

enum OnboardingIllustration {
    case books, notes, explore

    var symbolName: String {
        switch self {
        case .books: "books.vertical.fill"
        case .notes: "note.text"
        case .explore: "arrow.right.circle.fill"
        }
    }

    var badgeIcon: String {
        switch self {
        case .books: "lightbulb.fill"
        case .notes: "link"
        case .explore: "sparkles"
        }
    }

    var badgeLabel: String {
        switch self {
        case .books: "Structured learning"
        case .notes: "Linked notes"
        case .explore: "Ready to go"
        }
    }
}
