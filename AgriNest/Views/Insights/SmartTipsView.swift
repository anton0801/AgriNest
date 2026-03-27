import SwiftUI

struct SmartTipsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(Array(appState.smartTips.enumerated()), id: \.offset) { index, tip in
                        SmartTipCard(icon: tip.icon, text: tip.text, learnMoreTopic: tip.learnMoreTopic)
                    }

                    // Extra generic tips
                    SmartTipCard(
                        icon: "sun.max",
                        text: "High temperature may reduce egg production. Consider shading and ventilation for your flocks.",
                        learnMoreTopic: "Seasonal Tips"
                    )
                    SmartTipCard(
                        icon: "drop.triangle",
                        text: "Add calcium to feed to improve egg shell quality. Oyster shell is an excellent source.",
                        learnMoreTopic: "Egg Quality"
                    )
                    SmartTipCard(
                        icon: "thermometer",
                        text: "Check water quality — your flock drinks more in summer. Always provide clean, fresh water.",
                        learnMoreTopic: "Poultry Care"
                    )
                    SmartTipCard(
                        icon: "leaf.arrow.triangle.circlepath",
                        text: "Rotate crops annually to prevent soil depletion and reduce disease buildup.",
                        learnMoreTopic: "Crop Diseases"
                    )
                    SmartTipCard(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Track your feed conversion ratio weekly. Lower FCR means more efficient production.",
                        learnMoreTopic: "Feed Management"
                    )

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Smart Tips")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SmartTipCard: View {
    let icon: String
    let text: String
    let learnMoreTopic: String
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.peach)
                    .frame(width: 36, height: 36)
                    .background(AppColors.peach.opacity(0.15))
                    .clipShape(Circle())

                Text(text)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(3)
            }

            HStack {
                Spacer()
                NavigationLink(destination: knowledgeDestination) {
                    HStack(spacing: 4) {
                        Text("Learn More")
                            .font(AppFonts.captionBold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppColors.peach)
                }
            }
        }
        .padding(14)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }

    private var knowledgeDestination: some View {
        KnowledgeCardsView()
    }
}
