import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("AppPrimary").opacity(0.25),
                                Color("AppPrimary").opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color("AppPrimary"))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, 24)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .appCardDepth()
    }
}
