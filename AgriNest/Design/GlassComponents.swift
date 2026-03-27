import SwiftUI

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var opacity: Double
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(opacity))
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(.ultraThinMaterial)
                        )
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassCard(opacity: Double = 0.15, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(opacity: opacity, cornerRadius: cornerRadius))
    }

    func glassMediumCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(opacity: 0.22, cornerRadius: cornerRadius))
    }

    func glassDarkCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(opacity: 0.35, cornerRadius: cornerRadius))
    }
}

// MARK: - Glass Button
struct GlassButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        gradient: LinearGradient = LinearGradient(
            colors: [Color(hex: "7BAE7F"), Color(hex: "5A9E5E")],
            startPoint: .leading, endPoint: .trailing
        ),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(AppFonts.bodySemibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Status Chip
struct StatusChip: View {
    let text: String
    let status: HealthStatus

    var body: some View {
        Text(text)
            .font(AppFonts.captionBold)
            .foregroundColor(status.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(status.backgroundColor)
            .clipShape(Capsule())
    }
}

enum HealthStatus: String, Codable, CaseIterable {
    case healthy = "Healthy"
    case warning = "Check Required"
    case alert = "Alert"

    var color: Color {
        switch self {
        case .healthy: return AppColors.healthyGreen
        case .warning: return AppColors.warningYellow
        case .alert: return AppColors.alertRed
        }
    }

    var backgroundColor: Color {
        switch self {
        case .healthy: return AppColors.healthyChipBg
        case .warning: return AppColors.warningChipBg
        case .alert: return AppColors.alertChipBg
        }
    }
}

// MARK: - Grain Texture Overlay
struct GrainTexture: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<2000 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.08)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Background Gradient View
struct GradientBackground: View {
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()
        }
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            Text(value)
                .font(AppFonts.body(20, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
        .scaleEffect(appeared ? 1 : 0.8)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var actionTitle: String = "See All"
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.h2)
                .foregroundColor(.white)
            Spacer()
            if let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppFonts.bodySemibold)
                        .foregroundColor(AppColors.peach)
                }
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.white.opacity(0.4))
            Text(title)
                .font(AppFonts.h2)
                .foregroundColor(.white.opacity(0.7))
            Text(subtitle)
                .font(AppFonts.bodyRegular)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Simple Line Chart (iOS 15 compatible)
struct SimpleLineChart: View {
    let data: [Double]
    let lineColor: Color
    var height: CGFloat = 120

    var body: some View {
        GeometryReader { geometry in
            let maxVal = (data.max() ?? 1)
            let minVal = (data.min() ?? 0)
            let range = max(maxVal - minVal, 1)
            let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))

            ZStack {
                // Fill area
                Path { path in
                    guard data.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    for (index, value) in data.enumerated() {
                        let x = stepX * CGFloat(index)
                        let y = geometry.size.height - (CGFloat((value - minVal) / range) * geometry.size.height)
                        if index == 0 {
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.addLine(to: CGPoint(x: stepX * CGFloat(data.count - 1), y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [lineColor.opacity(0.3), lineColor.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Line
                Path { path in
                    guard data.count > 1 else { return }
                    for (index, value) in data.enumerated() {
                        let x = stepX * CGFloat(index)
                        let y = geometry.size.height - (CGFloat((value - minVal) / range) * geometry.size.height)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Simple Bar Chart (iOS 15 compatible)
struct SimpleBarChart: View {
    let data: [Double]
    let labels: [String]
    let barColor: Color
    var height: CGFloat = 120

    var body: some View {
        GeometryReader { geometry in
            let maxVal = max(data.max() ?? 1, 1)
            let barWidth = max((geometry.size.width / CGFloat(data.count)) - 8, 4)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<data.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor.opacity(0.8))
                            .frame(
                                width: barWidth,
                                height: max(CGFloat(data[index] / maxVal) * (geometry.size.height - 20), 2)
                            )
                        if index < labels.count {
                            Text(labels[index])
                                .font(AppFonts.small)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: height)
    }
}
