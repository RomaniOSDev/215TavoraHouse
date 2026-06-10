import SwiftUI

// MARK: - Shared gradient fills (lightweight 2-stop linear only)

enum AppDepthStyle {
    static let cardRadius: CGFloat = 14
    static let buttonRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.2
    static let shadowRadius: CGFloat = 10
    static let shadowY: CGFloat = 5

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppBackground").opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent"),
                Color("AppPrimary")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AppSurfaceFill: View {
    var body: some View {
        AppDepthStyle.surfaceGradient
    }
}

struct AppPrimaryFill: View {
    var body: some View {
        AppDepthStyle.primaryGradient
    }
}

struct AppChipSelectedFill: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color("AppPrimary"),
                Color("AppPrimary").opacity(0.82)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Optimized modifiers
// compositingGroup() batches layers → one shadow pass per view (GPU-friendly)

struct AppCardDepthModifier: ViewModifier {
    var accentBorder: Bool = false
    var radius: CGFloat = AppDepthStyle.cardRadius

    func body(content: Content) -> some View {
        content
            .background(AppSurfaceFill())
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("AppTextPrimary").opacity(0.14),
                                Color("AppTextPrimary").opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay {
                if accentBorder {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(Color("AppAccent").opacity(0.5), lineWidth: 1.5)
                }
            }
            .compositingGroup()
            .shadow(
                color: Color.black.opacity(AppDepthStyle.shadowOpacity),
                radius: AppDepthStyle.shadowRadius,
                x: 0,
                y: AppDepthStyle.shadowY
            )
    }
}

struct AppSoftShadowModifier: ViewModifier {
    var radius: CGFloat = AppDepthStyle.shadowRadius
    var y: CGFloat = AppDepthStyle.shadowY
    var opacity: Double = AppDepthStyle.shadowOpacity

    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .shadow(color: Color.black.opacity(opacity), radius: radius, x: 0, y: y)
    }
}

struct AppInsetSurfaceModifier: ViewModifier {
    var radius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.45),
                        Color("AppBackground").opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
            )
    }
}

struct AppSearchBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppSurfaceFill())
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1)
            )
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

struct AppIconPlateModifier: ViewModifier {
    var size: CGFloat = 48
    var highlighted: Bool = true

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: highlighted
                                ? [Color("AppPrimary").opacity(0.28), Color("AppPrimary").opacity(0.12)]
                                : [Color("AppBackground").opacity(0.5), Color("AppBackground").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
            )
    }
}

struct AppHeroCardModifier: ViewModifier {
    var radius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("AppTextPrimary").opacity(0.2),
                                Color("AppTextPrimary").opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func appCardDepth(accentBorder: Bool = false, radius: CGFloat = AppDepthStyle.cardRadius) -> some View {
        modifier(AppCardDepthModifier(accentBorder: accentBorder, radius: radius))
    }

    func appSoftShadow(
        radius: CGFloat = AppDepthStyle.shadowRadius,
        y: CGFloat = AppDepthStyle.shadowY,
        opacity: Double = AppDepthStyle.shadowOpacity
    ) -> some View {
        modifier(AppSoftShadowModifier(radius: radius, y: y, opacity: opacity))
    }

    func appInsetSurface(radius: CGFloat = 10) -> some View {
        modifier(AppInsetSurfaceModifier(radius: radius))
    }

    func appSearchBarStyle() -> some View {
        modifier(AppSearchBarModifier())
    }

    func appIconPlate(size: CGFloat = 48, highlighted: Bool = true) -> some View {
        modifier(AppIconPlateModifier(size: size, highlighted: highlighted))
    }

    func appHeroCardStyle(radius: CGFloat = 16) -> some View {
        modifier(AppHeroCardModifier(radius: radius))
    }
}
