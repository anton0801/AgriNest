import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditingProfile = false
    @State private var editedName = ""
    @State private var editedFarmName = ""
    @State private var editedFarmSize = ""
    @State private var editedRegion = ""
    @State private var showSaved = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.dashboardGradient.ignoresSafeArea()
                GrainTexture().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile header
                        VStack(spacing: 12) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(AppColors.plantGreen.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                Text(initials)
                                    .font(AppFonts.header(28))
                                    .foregroundColor(.white)
                            }

                            Text(appState.currentUser.fullName.isEmpty ? "Farmer" : appState.currentUser.fullName)
                                .font(AppFonts.header(24))
                                .foregroundColor(.white)

                            Text(appState.currentUser.farmName.isEmpty ? "My Farm" : appState.currentUser.farmName)
                                .font(AppFonts.bodyRegular)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 16)

                        // Profile info
                        VStack(spacing: 2) {
                            ProfileInfoRow(icon: "map", title: "Farm Size", value: appState.currentUser.farmSizeHectares > 0 ? "\(Int(appState.currentUser.farmSizeHectares)) ha" : "Not set")
                            ProfileInfoRow(icon: "globe", title: "Country", value: appState.currentUser.country.isEmpty ? "Not set" : appState.currentUser.country)
                            ProfileInfoRow(icon: "location", title: "Region", value: appState.currentUser.region.isEmpty ? "Not set" : appState.currentUser.region)
                            ProfileInfoRow(icon: "square.grid.2x2", title: "Farm Type", value: appState.currentUser.farmType.rawValue)
                            ProfileInfoRow(icon: "calendar", title: "Joined", value: formatDate(appState.currentUser.registrationDate))
                        }
                        .glassMediumCard()
                        .padding(.horizontal)

                        // Edit Profile button
                        GlassButton(title: "Edit Profile", icon: "pencil") {
                            editedName = appState.currentUser.fullName
                            editedFarmName = appState.currentUser.farmName
                            editedFarmSize = appState.currentUser.farmSizeHectares > 0 ? "\(Int(appState.currentUser.farmSizeHectares))" : ""
                            editedRegion = appState.currentUser.region
                            isEditingProfile = true
                        }
                        .padding(.horizontal)

                        // Navigation links
                        VStack(spacing: 2) {
                            NavigationLink(destination: FarmCalendarView()) {
                                ProfileMenuRow(icon: "calendar", title: "Farm Calendar", color: AppColors.peach)
                            }
                            NavigationLink(destination: FarmPhotoJournalView()) {
                                ProfileMenuRow(icon: "photo.on.rectangle", title: "Photo Journal", color: AppColors.plantGreen)
                            }
                            NavigationLink(destination: FarmInventoryView()) {
                                ProfileMenuRow(icon: "shippingbox", title: "Farm Inventory", color: AppColors.peachDark)
                            }
                            NavigationLink(destination: FarmProfitView()) {
                                ProfileMenuRow(icon: "chart.bar", title: "Farm Profit", color: AppColors.healthyGreen)
                            }
                            NavigationLink(destination: SettingsView()) {
                                ProfileMenuRow(icon: "gearshape", title: "Settings", color: .white)
                            }
                        }
                        .glassCard()
                        .padding(.horizontal)

                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isEditingProfile) {
                editProfileSheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var initials: String {
        let name = appState.currentUser.fullName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    private var editProfileSheet: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Edit Profile")
                        .font(AppFonts.header(24))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 14) {
                        GlassTextField(placeholder: "Full Name", text: $editedName, icon: "person")
                        GlassTextField(placeholder: "Farm Name", text: $editedFarmName, icon: "house")
                        GlassTextField(placeholder: "Farm Size (hectares)", text: $editedFarmSize, icon: "map")
                            .keyboardType(.numberPad)
                        GlassTextField(placeholder: "Region", text: $editedRegion, icon: "location")
                    }
                    .padding(.horizontal, 24)

                    GlassButton(title: showSaved ? "Saved!" : "Save Changes", icon: showSaved ? "checkmark" : "square.and.arrow.down") {
                        appState.currentUser.fullName = editedName
                        appState.currentUser.farmName = editedFarmName
                        appState.currentUser.farmSizeHectares = Double(editedFarmSize) ?? 0
                        appState.currentUser.region = editedRegion
                        withAnimation { showSaved = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showSaved = false }
                            isEditingProfile = false
                        }
                    }
                    .padding(.horizontal, 24)

                    Button("Cancel") {
                        isEditingProfile = false
                    }
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.peach)
                .frame(width: 20)
            Text(title)
                .font(AppFonts.bodyRegular)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(AppFonts.bodySemibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(title)
                .font(AppFonts.bodyRegular)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
