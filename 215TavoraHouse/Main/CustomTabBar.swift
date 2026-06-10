import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case topics
    case practice
    case progress
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .topics: return "Topics"
        case .practice: return "Practice"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .topics: return "book.fill"
        case .practice: return "lightbulb.fill"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    var dueReviewCount: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color("AppTextPrimary").opacity(0.1),
                    Color("AppTextPrimary").opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)

            HStack(spacing: 6) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [
                        Color("AppSurface"),
                        Color("AppBackground").opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.2), radius: 14, x: 0, y: -5)
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        let badgeCount = tab == .home ? dueReviewCount : 0

        Button {
            FeedbackService.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 5) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    Text(tab.title)
                        .font(.caption2.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        AppPrimaryFill()
                    } else {
                        Color.clear
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            Color("AppTextPrimary").opacity(isSelected ? 0.18 : 0.06),
                            lineWidth: 1
                        )
                )
                .scaleEffect(isSelected ? 1 : 0.96)

                if badgeCount > 0 {
                    Text("\(min(badgeCount, 99))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .offset(x: 6, y: -2)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}
