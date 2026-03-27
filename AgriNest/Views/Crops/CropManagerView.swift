import SwiftUI

struct CropManagerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddCrop = false

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if appState.crops.isEmpty {
                        EmptyStateView(
                            icon: "leaf",
                            title: "No Crops Yet",
                            subtitle: "Start tracking your crops by adding your first one."
                        )
                        .padding(.top, 60)
                    } else {
                        ForEach(appState.crops) { crop in
                            CropCard(crop: crop)
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Crop Manager")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddCrop = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.plantGreen)
                }
            }
        }
        .sheet(isPresented: $showAddCrop) {
            AddCropView()
                .environmentObject(appState)
        }
    }
}

struct CropCard: View {
    @EnvironmentObject var appState: AppState
    let crop: Crop
    @State private var appeared = false

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: crop.growthStage.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.plantGreen)
                    .frame(width: 44, height: 44)
                    .background(AppColors.plantGreen.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(crop.name)
                        .font(AppFonts.bodySemibold)
                        .foregroundColor(.white)
                    Text(crop.growthStage.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                StatusChip(text: crop.healthStatus.rawValue, status: crop.healthStatus)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Growth Progress")
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("\(Int(crop.growthStage.progress * 100))%")
                        .font(AppFonts.captionBold)
                        .foregroundColor(AppColors.plantGreen)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.plantGreen)
                            .frame(width: geo.size.width * crop.growthStage.progress)
                    }
                }
                .frame(height: 6)
            }

            HStack {
                Label("Water: \(dateFormatter.string(from: crop.nextWateringDate))", systemImage: "drop")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                if !crop.harvestForecast.isEmpty {
                    Label(crop.harvestForecast, systemImage: "basket")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.peach)
                }
            }

            // Action buttons
            HStack(spacing: 8) {
                Button(action: {
                    var updated = crop
                    // Advance growth stage
                    switch crop.growthStage {
                    case .seedling: updated.growthStage = .vegetative
                    case .vegetative: updated.growthStage = .flowering
                    case .flowering: updated.growthStage = .harvest
                    case .harvest: updated.growthStage = .harvest
                    }
                    appState.updateCrop(updated)
                }) {
                    Text("Advance Stage")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.plantGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.plantGreen.opacity(0.15))
                        .clipShape(Capsule())
                }

                Button(action: {
                    var updated = crop
                    updated.nextWateringDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
                    appState.updateCrop(updated)
                }) {
                    Text("Watered")
                        .font(AppFonts.caption)
                        .foregroundColor(Color(hex: "7B9EAE"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "7B9EAE").opacity(0.15))
                        .clipShape(Capsule())
                }

                Spacer()

                Button(action: {
                    appState.deleteCrop(crop)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.alertRed.opacity(0.6))
                        .padding(6)
                }
            }
        }
        .padding(14)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Add Crop
struct AddCropView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var growthStage: GrowthStage = .seedling
    @State private var nextWateringDate = Date()
    @State private var harvestForecast = ""
    @State private var notes = ""

    let suggestedCrops = ["Tomatoes", "Potatoes", "Corn", "Lettuce", "Peppers", "Cucumbers", "Beans", "Carrots"]

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Add New Crop")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    // Quick pick
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestedCrops, id: \.self) { crop in
                                Button(action: { name = crop }) {
                                    Text(crop)
                                        .font(AppFonts.caption)
                                        .foregroundColor(name == crop ? .white : .white.opacity(0.6))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(name == crop ? AppColors.plantGreen.opacity(0.4) : Color.white.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Crop Name", text: $name, icon: "leaf")
                        GlassTextField(placeholder: "Harvest Forecast (e.g., ~50kg)", text: $harvestForecast, icon: "basket")

                        // Growth stage
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Growth Stage")
                                .font(AppFonts.caption)
                                .foregroundColor(.white.opacity(0.7))
                            HStack(spacing: 8) {
                                ForEach(GrowthStage.allCases, id: \.self) { stage in
                                    Button(action: {
                                        withAnimation { growthStage = stage }
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: stage.icon)
                                                .font(.system(size: 16))
                                            Text(stage.rawValue)
                                                .font(AppFonts.small)
                                        }
                                        .foregroundColor(growthStage == stage ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(growthStage == stage ? AppColors.plantGreen.opacity(0.3) : Color.white.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        DatePicker("Next Watering", selection: $nextWateringDate, displayedComponents: .date)
                            .foregroundColor(.white)
                            .accentColor(AppColors.plantGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: "Add Crop", icon: "plus") {
                        guard !name.isEmpty else { return }
                        let crop = Crop(
                            name: name,
                            growthStage: growthStage,
                            nextWateringDate: nextWateringDate,
                            healthStatus: .healthy,
                            harvestForecast: harvestForecast,
                            plantedDate: Date(),
                            notes: notes
                        )
                        appState.addCrop(crop)
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
