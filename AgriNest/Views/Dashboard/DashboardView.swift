import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var appeared = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.dashboardGradient.ignoresSafeArea()
                GrainTexture().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greeting), \(appState.currentUser.fullName.isEmpty ? "Farmer" : appState.currentUser.fullName.components(separatedBy: " ").first ?? "Farmer")")
                                .font(AppFonts.header(26))
                                .foregroundColor(.white)
                            Text(dateString)
                                .font(AppFonts.bodyRegular)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Quick stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            NavigationLink(destination: PoultryManagerView()) {
                                QuickStatCard(
                                    icon: "bird",
                                    title: "Flocks",
                                    value: "\(appState.totalBirds)",
                                    color: AppColors.peach
                                )
                            }

                            NavigationLink(destination: CropManagerView()) {
                                QuickStatCard(
                                    icon: "leaf",
                                    title: "Crops",
                                    value: "\(appState.activeCrops)",
                                    color: AppColors.plantGreen
                                )
                            }

                            NavigationLink(destination: PhotoDiagnosticsView()) {
                                QuickStatCard(
                                    icon: "camera",
                                    title: "Diagnostics",
                                    value: "\(appState.pendingDiagnostics)",
                                    color: Color(hex: "7B9EAE")
                                )
                            }

                            NavigationLink(destination: FarmInsightsView()) {
                                QuickStatCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Health Score",
                                    value: "\(appState.healthScore)",
                                    color: AppColors.healthyGreen
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Tasks Today
                        NavigationLink(destination: FarmCalendarView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.peach)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Tasks Today")
                                        .font(AppFonts.bodySemibold)
                                        .foregroundColor(.white)
                                    Text("\(appState.todayTasks) events scheduled")
                                        .font(AppFonts.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(16)
                            .glassCard()
                        }
                        .padding(.horizontal)

                        // Quick Actions
                        SectionHeader(title: "Quick Actions")
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                NavigationLink(destination: FarmInventoryView()) {
                                    QuickActionCard(icon: "shippingbox", title: "Inventory", color: AppColors.peachDark)
                                }
                                NavigationLink(destination: SalesTrackerView()) {
                                    QuickActionCard(icon: "dollarsign.circle", title: "Sales", color: AppColors.plantGreen)
                                }
                                NavigationLink(destination: FarmPhotoJournalView()) {
                                    QuickActionCard(icon: "photo.on.rectangle", title: "Photo Journal", color: Color(hex: "7B9EAE"))
                                }
                                NavigationLink(destination: SmartTipsView()) {
                                    QuickActionCard(icon: "lightbulb", title: "Smart Tips", color: AppColors.peach)
                                }
                                NavigationLink(destination: FarmProfitView()) {
                                    QuickActionCard(icon: "chart.bar", title: "Profit", color: AppColors.healthyGreen)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Recent Activity
                        if !appState.diagnosticResults.isEmpty {
                            SectionHeader(title: "Recent Diagnostics")
                                .padding(.horizontal)

                            ForEach(appState.diagnosticResults.prefix(3)) { result in
                                HStack(spacing: 12) {
                                    Image(systemName: result.category == .animal ? "hare" : "leaf")
                                        .font(.system(size: 18))
                                        .foregroundColor(result.status.color)
                                        .frame(width: 36, height: 36)
                                        .background(result.status.backgroundColor)
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.diagnosisName)
                                            .font(AppFonts.bodySemibold)
                                            .foregroundColor(.white)
                                        Text(result.date, style: .relative)
                                            .font(AppFonts.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    StatusChip(text: result.status.rawValue, status: result.status)
                                }
                                .padding(12)
                                .glassCard()
                                .padding(.horizontal)
                            }
                        }

                        // Low stock warning
                        if !appState.lowStockItems.isEmpty {
                            SectionHeader(title: "Low Stock Alert")
                                .padding(.horizontal)

                            ForEach(appState.lowStockItems) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(AppColors.alertRed)
                                    Text(item.name)
                                        .font(AppFonts.bodySemibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(item.quantity)) \(item.unit)")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.alertRed)
                                }
                                .padding(12)
                                .glassCard()
                                .padding(.horizontal)
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .glassCard(cornerRadius: 14)
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}
