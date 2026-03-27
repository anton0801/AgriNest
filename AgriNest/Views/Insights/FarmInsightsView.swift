import SwiftUI

struct FarmInsightsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod = 0 // 0=week, 1=month, 2=quarter

    private var periodDays: Int {
        switch selectedPeriod {
        case 0: return 7
        case 1: return 30
        case 2: return 90
        default: return 7
        }
    }

    private var eggData: [Double] {
        let days = periodDays
        let calendar = Calendar.current
        return (0..<min(days, 14)).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            return Double(appState.eggRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.eggsCollected })
        }
    }

    private var feedData: [Double] {
        appState.flocks.map { $0.feedConsumptionKg }
    }

    private var feedLabels: [String] {
        appState.flocks.map { String($0.name.prefix(6)) }
    }

    var body: some View {
        ZStack {
            AppColors.analyticsGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Week").tag(0)
                        Text("Month").tag(1)
                        Text("Quarter").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Health Score
                    VStack(spacing: 12) {
                        Text("Farm Health Score")
                            .font(AppFonts.bodySemibold)
                            .foregroundColor(.white)

                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 10)
                                .frame(width: 100, height: 100)
                            Circle()
                                .trim(from: 0, to: CGFloat(appState.healthScore) / 100)
                                .stroke(
                                    scoreColor,
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                            Text("\(appState.healthScore)")
                                .font(AppFonts.header(28))
                                .foregroundColor(.white)
                        }

                        Text(scoreLabel)
                            .font(AppFonts.caption)
                            .foregroundColor(scoreColor)
                    }
                    .padding(16)
                    .glassMediumCard()
                    .padding(.horizontal)

                    // Egg Production Trend
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Egg Production Trend")
                            .font(AppFonts.bodySemibold)
                            .foregroundColor(.white)

                        if eggData.isEmpty || eggData.allSatisfy({ $0 == 0 }) {
                            Text("No egg data yet")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.4))
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                        } else {
                            SimpleLineChart(data: eggData, lineColor: AppColors.peach)
                        }
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal)

                    // Feed Consumption
                    if !feedData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feed Consumption (kg/day)")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(.white)

                            SimpleBarChart(
                                data: feedData,
                                labels: feedLabels,
                                barColor: AppColors.plantGreen
                            )
                        }
                        .padding(16)
                        .glassCard()
                        .padding(.horizontal)
                    }

                    // Crop Growth Progress
                    if !appState.crops.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Crop Growth Progress")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(.white)

                            ForEach(appState.crops) { crop in
                                HStack(spacing: 12) {
                                    Text(crop.name)
                                        .font(AppFonts.bodyRegular)
                                        .foregroundColor(.white)
                                        .frame(width: 80, alignment: .leading)

                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.white.opacity(0.1))
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(AppColors.plantGreen)
                                                .frame(width: geo.size.width * crop.growthStage.progress)
                                        }
                                    }
                                    .frame(height: 8)

                                    Text(crop.growthStage.rawValue)
                                        .font(AppFonts.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .frame(width: 70, alignment: .trailing)
                                }
                            }
                        }
                        .padding(16)
                        .glassCard()
                        .padding(.horizontal)
                    }

                    // Quick stats summary
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InsightStatCard(title: "Total Birds", value: "\(appState.totalBirds)", icon: "bird", color: AppColors.peach)
                        InsightStatCard(title: "Active Crops", value: "\(appState.activeCrops)", icon: "leaf", color: AppColors.plantGreen)
                        InsightStatCard(title: "Revenue", value: "$\(Int(appState.totalRevenue))", icon: "dollarsign.circle", color: AppColors.healthyGreen)
                        InsightStatCard(title: "Inventory Items", value: "\(appState.inventoryItems.count)", icon: "shippingbox", color: AppColors.peachDark)
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Farm Insights")
        .navigationBarTitleDisplayMode(.large)
    }

    private var scoreColor: Color {
        if appState.healthScore >= 80 { return AppColors.healthyGreen }
        if appState.healthScore >= 50 { return AppColors.warningYellow }
        return AppColors.alertRed
    }

    private var scoreLabel: String {
        if appState.healthScore >= 80 { return "Excellent" }
        if appState.healthScore >= 50 { return "Needs Attention" }
        return "Critical"
    }
}

struct InsightStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(AppFonts.body(18, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard()
    }
}
