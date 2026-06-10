import AudioToolbox
import UIKit

enum FeedbackService {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func softTap() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func tick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    static func bookmarkSound() {
        AudioServicesPlaySystemSound(1104)
    }
}
