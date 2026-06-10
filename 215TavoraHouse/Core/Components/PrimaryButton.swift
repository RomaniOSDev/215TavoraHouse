import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    if isDestructive {
                        Color.red.opacity(0.2)
                    } else {
                        AppPrimaryFill()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppDepthStyle.buttonRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppDepthStyle.buttonRadius, style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(isDestructive ? 0 : 0.15), lineWidth: 1)
                )
                .compositingGroup()
                .shadow(
                    color: Color.black.opacity(isDestructive ? 0.08 : 0.22),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
                .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.12)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.12)) { isPressed = false }
                }
        )
    }
}
