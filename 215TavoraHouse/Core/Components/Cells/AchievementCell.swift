import SwiftUI

struct AchievementCell: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.systemImage)
                .font(.title3)
                .foregroundStyle(isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.6))
                .appIconPlate(size: 52, highlighted: isUnlocked)

            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130)
        .appCardDepth(accentBorder: isUnlocked)
        .opacity(isUnlocked ? 1 : 0.82)
    }
}
