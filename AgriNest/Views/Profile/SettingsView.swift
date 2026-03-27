import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSignOutConfirm = false
    @State private var showResetConfirm = false
    @State private var showDeleteAccountConfirm = false

    var body: some View {
        ZStack {
            AppColors.dashboardGradient.ignoresSafeArea()
            GrainTexture().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Units
                    VStack(alignment: .leading, spacing: 2) {
                        SettingsSectionHeader(title: "Units")
                        SettingsToggleRow(
                            icon: "ruler",
                            title: "Metric Units",
                            subtitle: appState.useMetricUnits ? "kg, hectares, °C" : "lbs, acres, °F",
                            isOn: $appState.useMetricUnits
                        )
                    }
                    .glassMediumCard()
                    .padding(.horizontal)

                    // Notifications
                    VStack(alignment: .leading, spacing: 2) {
                        SettingsSectionHeader(title: "Notifications")
                        SettingsToggleRow(
                            icon: "bell",
                            title: "Enable Notifications",
                            subtitle: "Receive farm reminders",
                            isOn: Binding(
                                get: { appState.notificationsEnabled },
                                set: { newValue in
                                    appState.notificationsEnabled = newValue
                                    if newValue {
                                        requestNotificationPermission()
                                    } else {
                                        cancelAllNotifications()
                                    }
                                }
                            )
                        )

                        if appState.notificationsEnabled {
                            SettingsToggleRow(
                                icon: "syringe",
                                title: "Vaccination Reminders",
                                subtitle: "1 day before scheduled",
                                isOn: Binding(
                                    get: { appState.notifyVaccination },
                                    set: { newValue in
                                        appState.notifyVaccination = newValue
                                        updateNotificationSchedule()
                                    }
                                )
                            )
                            SettingsToggleRow(
                                icon: "drop",
                                title: "Watering Reminders",
                                subtitle: "When crops need water",
                                isOn: Binding(
                                    get: { appState.notifyWatering },
                                    set: { newValue in
                                        appState.notifyWatering = newValue
                                        updateNotificationSchedule()
                                    }
                                )
                            )
                            SettingsToggleRow(
                                icon: "oval",
                                title: "Egg Collection",
                                subtitle: "Daily morning reminder",
                                isOn: Binding(
                                    get: { appState.notifyEggCollection },
                                    set: { newValue in
                                        appState.notifyEggCollection = newValue
                                        updateNotificationSchedule()
                                    }
                                )
                            )
                            SettingsToggleRow(
                                icon: "exclamationmark.triangle",
                                title: "Low Stock Alerts",
                                subtitle: "When inventory runs low",
                                isOn: Binding(
                                    get: { appState.notifyLowStock },
                                    set: { newValue in
                                        appState.notifyLowStock = newValue
                                        updateNotificationSchedule()
                                    }
                                )
                            )
                            SettingsToggleRow(
                                icon: "chart.bar.doc.horizontal",
                                title: "Weekly Report",
                                subtitle: "Sunday summary of farm activity",
                                isOn: Binding(
                                    get: { appState.notifyWeeklyReport },
                                    set: { newValue in
                                        appState.notifyWeeklyReport = newValue
                                        updateNotificationSchedule()
                                    }
                                )
                            )
                        }
                    }
                    .glassMediumCard()
                    .padding(.horizontal)

                    // Data
                    VStack(alignment: .leading, spacing: 2) {
                        SettingsSectionHeader(title: "Data")
                        Button(action: { showResetConfirm = true }) {
                            SettingsNavRow(icon: "arrow.counterclockwise", title: "Reset All Data", color: AppColors.alertRed)
                        }
                    }
                    .glassMediumCard()
                    .padding(.horizontal)

                    // About
                    VStack(alignment: .leading, spacing: 2) {
                        SettingsSectionHeader(title: "About")
                        SettingsInfoRow(icon: "info.circle", title: "Version", value: "1.0.0")
                        Button(action: {}) {
                            SettingsNavRow(icon: "doc.text", title: "Privacy Policy", color: .white)
                        }
                        Button(action: {}) {
                            SettingsNavRow(icon: "doc.plaintext", title: "Terms of Service", color: .white)
                        }
                    }
                    .glassMediumCard()
                    .padding(.horizontal)

                    // Sign Out
                    Button(action: { showSignOutConfirm = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(AppFonts.bodySemibold)
                        .foregroundColor(AppColors.alertRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.alertRed.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.alertRed.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    // Delete Account
                    Button(action: { showDeleteAccountConfirm = true }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                            Text("Delete Account")
                        }
                        .font(AppFonts.bodySemibold)
                        .foregroundColor(AppColors.alertRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.alertRed.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.alertRed.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Reset All Data", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will delete all your farm data. This action cannot be undone.")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                appState.deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account, all farm data, and settings. This action cannot be undone.")
        }
    }

    // MARK: - Notification Logic
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    appState.notificationsEnabled = false
                } else {
                    updateNotificationSchedule()
                }
            }
        }
    }

    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func updateNotificationSchedule() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard appState.notificationsEnabled else { return }

        // Egg collection — daily at 7 AM
        if appState.notifyEggCollection {
            let content = UNMutableNotificationContent()
            content.title = "Egg Collection"
            content.body = "Time to collect eggs from your flocks!"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = 7
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "egg-collection", content: content, trigger: trigger)
            center.add(request)
        }

        // Weekly report — Sunday at 9 AM
        if appState.notifyWeeklyReport {
            let content = UNMutableNotificationContent()
            content.title = "Weekly Farm Report"
            content.body = "Check your weekly farm performance summary."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = 1
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "weekly-report", content: content, trigger: trigger)
            center.add(request)
        }

        // Vaccination reminders — based on calendar events
        if appState.notifyVaccination {
            let vaccinations = appState.calendarEvents.filter { $0.eventType == .vaccination && $0.date > Date() }
            for (index, event) in vaccinations.prefix(10).enumerated() {
                let content = UNMutableNotificationContent()
                content.title = "Vaccination Reminder"
                content.body = "\(event.title) is scheduled for tomorrow."
                content.sound = .default

                if let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: event.date) {
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "vaccination-\(index)", content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }

        // Low stock alerts — check daily at 8 AM
        if appState.notifyLowStock && !appState.lowStockItems.isEmpty {
            let content = UNMutableNotificationContent()
            content.title = "Low Stock Alert"
            content.body = "\(appState.lowStockItems.count) items need restocking: \(appState.lowStockItems.prefix(3).map(\.name).joined(separator: ", "))"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = 8
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "low-stock", content: content, trigger: trigger)
            center.add(request)
        }

        // Watering reminders
        if appState.notifyWatering {
            let cropsNeedingWater = appState.crops.filter { $0.nextWateringDate <= Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date() }
            if !cropsNeedingWater.isEmpty {
                let content = UNMutableNotificationContent()
                content.title = "Watering Reminder"
                content.body = "Crops needing water: \(cropsNeedingWater.map(\.name).joined(separator: ", "))"
                content.sound = .default

                var dateComponents = DateComponents()
                dateComponents.hour = 6
                dateComponents.minute = 30
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "watering", content: content, trigger: trigger)
                center.add(request)
            }
        }
    }

    private func resetAllData() {
        appState.flocks = []
        appState.eggRecords = []
        appState.crops = []
        appState.diagnosticResults = []
        appState.calendarEvents = []
        appState.inventoryItems = []
        appState.sales = []
        appState.expenses = []
        appState.farmPhotos = []
        appState.courses = SampleCourses.courses
        cancelAllNotifications()
    }
}

// MARK: - Settings Row Components
struct SettingsSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppFonts.captionBold)
            .foregroundColor(.white.opacity(0.5))
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 4)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.peach)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFonts.bodyRegular)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.plantGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct SettingsNavRow: View {
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
                .foregroundColor(color)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsInfoRow: View {
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
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(AppFonts.bodyRegular)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
