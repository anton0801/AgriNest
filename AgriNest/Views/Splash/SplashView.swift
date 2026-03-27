import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var sunOffset: CGFloat = 50
    @State private var textOpacity: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var roofAngle: Double = -10

    var body: some View {
        ZStack {
            // Background
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            // Floating particles
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.05...0.15)))
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .opacity(particleOpacity)
            }

            VStack(spacing: 24) {
                Spacer()

                // Farm illustration
                ZStack {
                    // Sun
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .offset(x: 50, y: -sunOffset)

                    // Barn/coop
                    VStack(spacing: 0) {
                        // Roof
                        Triangle()
                            .fill(AppColors.peachDark)
                            .frame(width: 100, height: 40)
                            .rotationEffect(.degrees(roofAngle))

                        // Building
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.peach.opacity(0.8))
                            .frame(width: 80, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 20, height: 25)
                                    .offset(y: 5)
                            )
                    }

                    // Plants
                    HStack(spacing: 8) {
                        PlantShape()
                            .offset(x: -70, y: 20)
                        PlantShape()
                            .offset(x: 70, y: 25)
                        PlantShape()
                            .offset(x: 85, y: 15)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Logo text
                VStack(spacing: 8) {
                    Text("Angri Nest")
                        .font(AppFonts.header(36))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    Text("Smart companion for modern farmers.")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                sunOffset = 80
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                roofAngle = 0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                textOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                particleOpacity = 1.0
            }
        }
    }
}

// MARK: - Helper Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PlantShape: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.plantGreen)
                .rotationEffect(.degrees(-15))
            Rectangle()
                .fill(AppColors.plantGreen.opacity(0.6))
                .frame(width: 2, height: 15)
        }
    }
}
