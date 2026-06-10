import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppSurface"),
                    Color("AppBackground").opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color("AppPrimary").opacity(0.1),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 280
            )

            RadialGradient(
                colors: [
                    Color("AppAccent").opacity(0.08),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 5,
                endRadius: 220
            )
        }
        .ignoresSafeArea()
        //.drawingGroup()
    }
}
