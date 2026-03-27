import SwiftUI

struct EggProductionView: View {
    @EnvironmentObject var appState: AppState
    let flockId: UUID
    @State private var showAddRecord = false
    @State private var selectedPeriod = 0 // 0 = 7 days, 1 = 30 days

    private var records: [EggRecord] {
        appState.eggRecords(for: flockId)
    }

    private var filteredRecords: [EggRecord] {
        let days = selectedPeriod == 0 ? 7 : 30
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return records.filter { $0.date >= cutoff }
    }

    private var chartData: [Double] {
        filteredRecords.reversed().map { Double($0.eggsCollected) }
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Period picker
                    Picker("Period", selection: $selectedPeriod) {
                        Text("7 Days").tag(0)
                        Text("30 Days").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Chart
                    if !chartData.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Production Trend")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(.white)
                            SimpleLineChart(data: chartData, lineColor: AppColors.peach)
                        }
                        .padding(16)
                        .glassMediumCard()
                        .padding(.horizontal)
                    }

                    // Records table
                    SectionHeader(title: "Records")
                        .padding(.horizontal)

                    if records.isEmpty {
                        EmptyStateView(
                            icon: "oval",
                            title: "No Records",
                            subtitle: "Start tracking egg production by adding your first record."
                        )
                    } else {
                        // Table header
                        HStack {
                            Text("Date")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Collected")
                                .frame(width: 65)
                            Text("Broken")
                                .frame(width: 55)
                            Text("Sold")
                                .frame(width: 45)
                        }
                        .font(AppFonts.captionBold)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 28)

                        ForEach(records) { record in
                            HStack {
                                Text(formatDate(record.date))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(record.eggsCollected)")
                                    .frame(width: 65)
                                    .foregroundColor(AppColors.peach)
                                Text("\(record.brokenEggs)")
                                    .frame(width: 55)
                                    .foregroundColor(record.brokenEggs > 0 ? AppColors.alertRed : .white.opacity(0.6))
                                Text("\(record.soldEggs)")
                                    .frame(width: 45)
                            }
                            .font(AppFonts.bodyRegular)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassCard()
                            .padding(.horizontal)
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Egg Production")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddRecord = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddRecord) {
            AddEggRecordView(flockId: flockId)
                .environmentObject(appState)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
