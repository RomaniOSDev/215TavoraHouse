import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppPrimary"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    FeedbackService.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .appSearchBarStyle()
    }
}
