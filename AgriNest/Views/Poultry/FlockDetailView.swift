import SwiftUI

struct FlockDetailView: View {
    @EnvironmentObject var appState: AppState
    let flock: Flock
    @State private var showAddEggs = false
    @State private var editedFlock: Flock
    @State private var isEditing = false

    init(flock: Flock) {
        self.flock = flock
        _editedFlock = State(initialValue: flock)
    }

    private var flockEggRecords: [EggRecord] {
        appState.eggRecords(for: flock.id)
    }

    private var todayEggs: Int {
        flockEggRecords.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.eggsCollected }
    }

    private var weekEggs: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return flockEggRecords.filter { $0.date >= weekAgo }.reduce(0) { $0 + $1.eggsCollected }
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Flock header card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "bird.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppColors.peach)
                            VStack(alignment: .leading) {
                                Text(flock.name)
                                    .font(AppFonts.h2)
                                    .foregroundColor(.white)
                                Text("\(flock.birdType.rawValue) · \(flock.ageWeeks) weeks old")
                                    .font(AppFonts.bodyRegular)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            StatusChip(text: flock.healthStatus.rawValue, status: flock.healthStatus)
                        }

                        // Stats row
                        HStack(spacing: 0) {
                            StatItem(title: "Birds", value: "\(flock.birdCount)")
                            StatItem(title: "Mortality", value: String(format: "%.1f%%", flock.mortalityPercent))
                            StatItem(title: "Feed/Day", value: String(format: "%.1fkg", flock.feedConsumptionKg))
                        }
                    }
                    .padding(16)
                    .glassMediumCard()

                    // Egg production summary
                    VStack(spacing: 12) {
                        SectionHeader(title: "Egg Production")

                        HStack(spacing: 12) {
                            EggStatCard(title: "Today", value: "\(todayEggs)", icon: "sun.max")
                            EggStatCard(title: "This Week", value: "\(weekEggs)", icon: "calendar")
                        }
                    }

                    // Action buttons
                    HStack(spacing: 12) {
                        GlassButton(
                            title: "Add Eggs",
                            icon: "plus.circle",
                            gradient: LinearGradient(colors: [AppColors.peach, AppColors.peachDark], startPoint: .leading, endPoint: .trailing)
                        ) {
                            showAddEggs = true
                        }

                        NavigationLink(destination: EggProductionView(flockId: flock.id)) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("View Records")
                                    .font(AppFonts.bodySemibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // Health check button
                    NavigationLink(destination: HealthCheckView(flock: flock)) {
                        HStack {
                            Image(systemName: "stethoscope")
                                .foregroundColor(AppColors.healthyGreen)
                            Text("Health Check")
                                .font(AppFonts.bodySemibold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(14)
                        .glassCard()
                    }

                    // Recent egg records
                    if !flockEggRecords.isEmpty {
                        SectionHeader(title: "Recent Records")

                        ForEach(flockEggRecords.prefix(5)) { record in
                            HStack {
                                Text(record.date, style: .date)
                                    .font(AppFonts.bodyRegular)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(record.eggsCollected) eggs")
                                    .font(AppFonts.bodySemibold)
                                    .foregroundColor(AppColors.peach)
                                if record.brokenEggs > 0 {
                                    Text("(\(record.brokenEggs) broken)")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.alertRed)
                                }
                            }
                            .padding(12)
                            .glassCard()
                        }
                    }

                    // Delete flock
                    Button(action: {
                        appState.deleteFlock(flock)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Flock")
                        }
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(AppColors.alertRed.opacity(0.8))
                        .padding(.top, 20)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle(flock.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddEggs) {
            AddEggRecordView(flockId: flock.id)
                .environmentObject(appState)
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.body(18, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct EggStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.peach)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppFonts.body(20, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard()
    }
}

// MARK: - Add Egg Record
struct AddEggRecordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let flockId: UUID
    @State private var eggsCollected = ""
    @State private var brokenEggs = ""
    @State private var soldEggs = ""
    @State private var date = Date()

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Add Egg Record")
                    .font(AppFonts.header(24))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                VStack(spacing: 14) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .accentColor(AppColors.peach)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    GlassTextField(placeholder: "Eggs Collected", text: $eggsCollected, icon: "oval")
                        .keyboardType(.numberPad)
                    GlassTextField(placeholder: "Broken Eggs", text: $brokenEggs, icon: "xmark.circle")
                        .keyboardType(.numberPad)
                    GlassTextField(placeholder: "Sold Eggs", text: $soldEggs, icon: "dollarsign.circle")
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 24)

                GlassButton(title: "Save Record", icon: "checkmark") {
                    let record = EggRecord(
                        flockId: flockId,
                        date: date,
                        eggsCollected: Int(eggsCollected) ?? 0,
                        brokenEggs: Int(brokenEggs) ?? 0,
                        soldEggs: Int(soldEggs) ?? 0
                    )
                    appState.addEggRecord(record)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal, 24)

                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(AppFonts.bodyRegular)
                .foregroundColor(.white.opacity(0.6))

                Spacer()
            }
        }
    }
}

// MARK: - Health Check View
struct HealthCheckView: View {
    @EnvironmentObject var appState: AppState
    let flock: Flock
    @State private var selectedStatus: HealthStatus
    @State private var notes = ""
    @State private var saved = false

    init(flock: Flock) {
        self.flock = flock
        _selectedStatus = State(initialValue: flock.healthStatus)
    }

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Health Check")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 16)

                    Text("Assess the health status of \(flock.name)")
                        .font(AppFonts.bodyRegular)
                        .foregroundColor(.white.opacity(0.7))

                    // Status selection
                    VStack(spacing: 12) {
                        ForEach(HealthStatus.allCases, id: \.self) { status in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedStatus = status
                                }
                            }) {
                                HStack {
                                    Circle()
                                        .fill(status.color)
                                        .frame(width: 12, height: 12)
                                    Text(status.rawValue)
                                        .font(AppFonts.bodySemibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if selectedStatus == status {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(status.color)
                                    }
                                }
                                .padding(14)
                                .background(selectedStatus == status ? status.backgroundColor : Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedStatus == status ? status.color.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: saved ? "Saved!" : "Save Health Check", icon: saved ? "checkmark" : "stethoscope") {
                        var updated = flock
                        updated.healthStatus = selectedStatus
                        appState.updateFlock(updated)
                        withAnimation { saved = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { saved = false }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
        }
        .navigationTitle("Health Check")
        .navigationBarTitleDisplayMode(.inline)
    }
}
