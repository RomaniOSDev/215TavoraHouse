import SwiftUI

struct SettingsMenuCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(isDestructive ? Color.red : Color("AppPrimary"))
                    .appIconPlate(size: 36, highlighted: !isDestructive)

                Text(title)
                    .font(.body)
                    .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}
