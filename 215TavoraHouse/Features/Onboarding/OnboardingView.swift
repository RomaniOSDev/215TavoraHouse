import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var store: AppDataStore
    @State private var illustrationScale: CGFloat = 0.92
    @State private var illustrationOpacity: Double = 0

    var body: some View {
        GeometryReader { proxy in
            let topInset = max(proxy.safeAreaInsets.top * 0.15, 4)

            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    onboardingHeader
                        .padding(.horizontal, 24)
                        .padding(.top, topInset)
                        .padding(.bottom, 4)

                    TabView(selection: $viewModel.currentPage) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                            onboardingPage(page: page, index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                    .padding(.top, 14)
                    .frame(maxHeight: .infinity)

                    onboardingFooter
                }
                //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            //.ignoresSafeArea(edges: .top)
            //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: viewModel.currentPage) { _ in
            animateIllustration()
        }
        .onAppear {
            animateIllustration()
        }
    }

    // MARK: - Header

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Step \(viewModel.currentPage + 1) of \(viewModel.pages.count)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .appInsetSurface(radius: 20)

                Spacer()

                Text(viewModel.pages[viewModel.currentPage].illustration.badgeLabel)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color("AppPrimary").opacity(0.18))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
                    )
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground").opacity(0.45))
                        .overlay(
                            Capsule()
                                .stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
                        )

                    Capsule()
                        .fill(AppDepthStyle.primaryGradient)
                        .frame(width: max(geo.size.width * viewModel.progress, 12))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentPage)
                }
            }
            .frame(height: 6)
            .compositingGroup()
            .appSoftShadow(radius: 4, y: 2, opacity: 0.1)
        }
    }

    // MARK: - Page

    @ViewBuilder
    private func onboardingPage(
        page: (headline: String, description: String, illustration: OnboardingIllustration),
        index: Int
    ) -> some View {
        VStack(spacing: 16) {
            illustrationPanel(for: page.illustration)
                .scaleEffect(illustrationScale)
                .opacity(illustrationOpacity)

            AppCard(accentBorder: index == viewModel.currentPage) {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: page.illustration.symbolName)
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppPrimary"))
                            .appIconPlate(size: 44, highlighted: true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(page.headline)
                                .font(.title2.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Feature \(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppAccent"))
                        }

                        Spacer(minLength: 0)
                    }

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("AppPrimary").opacity(0.5),
                                    Color("AppTextPrimary").opacity(0.08)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Footer

    private var onboardingFooter: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<viewModel.pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == viewModel.currentPage
                                ? AnyShapeStyle(AppDepthStyle.primaryGradient)
                                : AnyShapeStyle(Color("AppTextSecondary").opacity(0.35))
                        )
                        .frame(width: index == viewModel.currentPage ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.currentPage)
                }
            }

            PrimaryButton(title: viewModel.buttonTitle) {
                viewModel.nextPage {
                    store.completeOnboarding()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Illustrations

    @ViewBuilder
    private func illustrationPanel(for type: OnboardingIllustration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppPrimary").opacity(0.22),
                            Color("AppBackground").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            illustrationContent(for: type)
                .padding(24)
        }
        .frame(height: 220)
        .appHeroCardStyle(radius: 20)
    }

    @ViewBuilder
    private func illustrationContent(for type: OnboardingIllustration) -> some View {
        switch type {
        case .books:
            ZStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.7))
                    .offset(x: -52, y: 18)
                    .appIconPlate(size: 64, highlighted: false)

                Image(systemName: type.symbolName)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .appIconPlate(size: 88, highlighted: true)
                    .appSoftShadow(radius: 8, y: 4, opacity: 0.15)

                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color("AppAccent"))
                    .offset(x: 58, y: -20)
                    .appIconPlate(size: 56, highlighted: true)
            }
            .compositingGroup()

        case .notes:
            VStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppDepthStyle.surfaceGradient)
                        .frame(width: 180, height: 120)
                        .overlay(
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<3, id: \.self) { i in
                                    Capsule()
                                        .fill(Color("AppTextSecondary").opacity(0.45))
                                        .frame(width: CGFloat(120 - i * 18), height: 5)
                                }
                            }
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1)
                        )

                    Image(systemName: type.badgeIcon)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .padding(8)
                        .background(Circle().fill(Color("AppSurface")))
                        .overlay(Circle().stroke(Color("AppAccent").opacity(0.4), lineWidth: 1))
                        .offset(x: 10, y: -10)
                }
                .compositingGroup()
                .appSoftShadow(radius: 8, y: 4, opacity: 0.14)

                HStack(spacing: 8) {
                    Image(systemName: "pencil.line")
                        .font(.caption.bold())
                    Text("Capture & connect ideas")
                        .font(.caption.bold())
                }
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .appInsetSurface(radius: 20)
            }

        case .explore:
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent"), Color("AppPrimary")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 130, height: 130)
                    .opacity(0.85)

                Image(systemName: type.symbolName)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .appIconPlate(size: 80, highlighted: true)

                Image(systemName: type.badgeIcon)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color("AppSurface").opacity(0.9))
                    )
                    .offset(x: 54, y: -54)
            }
            .compositingGroup()
            .appSoftShadow(radius: 8, y: 4, opacity: 0.12)
        }
    }

    private func animateIllustration() {
        illustrationScale = 0.92
        illustrationOpacity = 0
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            illustrationScale = 1
            illustrationOpacity = 1
        }
    }
}
