import SwiftUI

struct SuccessCheckmarkBadge: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
        }
    }

    static func trigger(_ binding: Binding<Bool>) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            binding.wrappedValue = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                binding.wrappedValue = false
            }
        }
    }
}
