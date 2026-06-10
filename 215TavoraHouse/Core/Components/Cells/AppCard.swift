import SwiftUI

struct AppCard<Content: View>: View {
    var accentBorder: Bool = false
    var padding: CGFloat = 16
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardDepth(accentBorder: accentBorder)
    }
}
