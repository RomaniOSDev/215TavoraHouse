import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.systemImage)
                .font(.title2)
                .foregroundStyle(Color("AppPrimary"))
                .appIconPlate(size: 44, highlighted: true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            Spacer()
        }
        .padding(16)
        .appCardDepth(accentBorder: true)
        .padding(.horizontal, 16)
    }
}
