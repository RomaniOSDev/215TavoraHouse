import SwiftUI

struct CategoryChipView: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    AppChipSelectedFill()
                } else {
                    AppSurfaceFill()
                }
            }
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        Color("AppTextPrimary").opacity(isSelected ? 0.15 : 0.08),
                        lineWidth: 1
                    )
            )
            .compositingGroup()
            .shadow(
                color: Color.black.opacity(isSelected ? 0.18 : 0.08),
                radius: isSelected ? 6 : 3,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}
