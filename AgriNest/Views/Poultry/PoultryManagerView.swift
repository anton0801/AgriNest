import SwiftUI

struct PoultryManagerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddFlock = false

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if appState.flocks.isEmpty {
                        EmptyStateView(
                            icon: "bird",
                            title: "No Flocks Yet",
                            subtitle: "Add your first flock to start tracking your poultry."
                        )
                        .padding(.top, 60)
                    } else {
                        ForEach(appState.flocks) { flock in
                            NavigationLink(destination: FlockDetailView(flock: flock)) {
                                FlockCard(flock: flock)
                            }
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Poultry Manager")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddFlock = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.peach)
                }
            }
        }
        .sheet(isPresented: $showAddFlock) {
            AddFlockView()
                .environmentObject(appState)
        }
    }
}

struct FlockCard: View {
    let flock: Flock
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: "bird.fill")
                .font(.system(size: 28))
                .foregroundColor(AppColors.peach)
                .frame(width: 52, height: 52)
                .background(AppColors.peach.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(flock.name)
                    .font(AppFonts.bodySemibold)
                    .foregroundColor(.white)
                Text("\(flock.birdCount) \(flock.birdType.rawValue) · \(flock.ageWeeks) weeks")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            StatusChip(text: flock.healthStatus.rawValue, status: flock.healthStatus)
        }
        .padding(14)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Add Flock
struct AddFlockView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var birdCount = ""
    @State private var birdType: BirdType = .hens
    @State private var ageWeeks = ""
    @State private var healthStatus: HealthStatus = .healthy

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add New Flock")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Flock Name (e.g., Flock A)", text: $name, icon: "bird")
                        GlassTextField(placeholder: "Number of Birds", text: $birdCount, icon: "number")
                            .keyboardType(.numberPad)
                        GlassTextField(placeholder: "Age (weeks)", text: $ageWeeks, icon: "clock")
                            .keyboardType(.numberPad)

                        // Bird type picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bird Type")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 8) {
                                ForEach(BirdType.allCases, id: \.self) { type in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            birdType = type
                                        }
                                    }) {
                                        Text(type.rawValue)
                                            .font(AppFonts.caption)
                                            .foregroundColor(birdType == type ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(birdType == type ? AppColors.plantGreen.opacity(0.4) : Color.white.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // Health status picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Health Status")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 8) {
                                ForEach(HealthStatus.allCases, id: \.self) { status in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            healthStatus = status
                                        }
                                    }) {
                                        StatusChip(text: status.rawValue, status: status)
                                            .opacity(healthStatus == status ? 1 : 0.5)
                                            .scaleEffect(healthStatus == status ? 1.05 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Flock", icon: "plus") {
                        guard !name.isEmpty, let count = Int(birdCount), let age = Int(ageWeeks) else { return }
                        let flock = Flock(
                            name: name,
                            birdCount: count,
                            birdType: birdType,
                            ageWeeks: age,
                            healthStatus: healthStatus
                        )
                        appState.addFlock(flock)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.horizontal, 24)

                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
