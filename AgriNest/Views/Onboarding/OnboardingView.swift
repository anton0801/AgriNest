import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.circle.fill",
            title: "Manage Your Farm",
            subtitle: "Track flocks, crops, inventory, and sales — all in one place.",
            color: AppColors.plantGreen,
            shapes: ["bird.fill", "leaf.fill", "shippingbox.fill"]
        ),
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Photo Diagnostics",
            subtitle: "Snap a photo of your plant or animal to get instant health insights.",
            color: AppColors.peach,
            shapes: ["camera.fill", "wand.and.stars", "checkmark.circle.fill"]
        ),
        OnboardingPage(
            icon: "book.circle.fill",
            title: "Learn & Grow",
            subtitle: "Mini-courses, knowledge cards, and quizzes to sharpen your farming skills.",
            color: Color(hex: "7B9EAE"),
            shapes: ["lightbulb.fill", "text.book.closed.fill", "star.fill"]
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            title: "Farm Analytics",
            subtitle: "Data-driven insights to help you make smarter decisions for your farm.",
            color: Color(hex: "6B9E5E"),
            shapes: ["chart.bar.fill", "arrow.up.right", "dollarsign.circle.fill"]
        )
    ]

    var body: some View {
        ZStack {
            // Background
            pages[currentPage].color.opacity(0.15)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: completeOnboarding) {
                        Text("Skip")
                            .font(AppFonts.bodySemibold)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.top, 8)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                // Next / Get Started button
                GlassButton(
                    title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                    icon: currentPage == pages.count - 1 ? "arrow.right" : "chevron.right"
                ) {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let shapes: [String]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false
    @State private var floatingOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration area
            ZStack {
                // Background circle
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .scaleEffect(appeared ? 1 : 0.5)

                // Floating shapes
                ForEach(0..<page.shapes.count, id: \.self) { index in
                    Image(systemName: page.shapes[index])
                        .font(.system(size: 24))
                        .foregroundColor(page.color.opacity(0.6))
                        .offset(
                            x: CGFloat(cos(Double(index) * 2.1)) * 80,
                            y: CGFloat(sin(Double(index) * 2.1)) * 80 + floatingOffset * (index % 2 == 0 ? 1 : -1)
                        )
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.6).delay(Double(index) * 0.15),
                            value: appeared
                        )
                }

                // Main icon
                Image(systemName: page.icon)
                    .font(.system(size: 72))
                    .foregroundColor(page.color)
                    .scaleEffect(appeared ? 1 : 0.3)
                    .rotationEffect(.degrees(appeared ? 0 : -30))
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppFonts.header(28))
                    .foregroundColor(.white)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Text(page.subtitle)
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatingOffset = 8
            }
        }
        .onDisappear {
            appeared = false
            floatingOffset = 0
        }
    }
}
