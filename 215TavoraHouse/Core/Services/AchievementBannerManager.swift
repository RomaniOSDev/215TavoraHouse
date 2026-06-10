import Combine
import SwiftUI

final class AchievementBannerManager: ObservableObject {
    @Published var currentBanner: Achievement?
    @Published var isVisible = false

    private var queue: [Achievement] = []
    private var isProcessing = false

    func showUnlock(for achievement: Achievement) {
        queue.append(achievement)
        processQueueIfNeeded()
    }

    private func processQueueIfNeeded() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        let next = queue.removeFirst()
        currentBanner = next
        FeedbackService.success()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self else { return }
                self.currentBanner = nil
                self.isProcessing = false
                self.processQueueIfNeeded()
            }
        }
    }
}
