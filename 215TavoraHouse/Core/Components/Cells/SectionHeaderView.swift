import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var icon: String?
    var tint: Color = Color("AppTextPrimary")

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(tint)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}
