import SwiftUI
import Combine
import UserNotifications

class AppState: ObservableObject {
    // Auth state
    @Published var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated") }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    @Published var showSplash = true

    // User
    @Published var currentUser: FarmUser {
        didSet { DataStore.shared.save(currentUser, to: "currentUser.json") }
    }

    // Flocks
    @Published var flocks: [Flock] {
        didSet { DataStore.shared.save(flocks, to: "flocks.json") }
    }
    @Published var eggRecords: [EggRecord] {
        didSet { DataStore.shared.save(eggRecords, to: "eggRecords.json") }
    }

    // Crops
    @Published var crops: [Crop] {
        didSet { DataStore.shared.save(crops, to: "crops.json") }
    }

    // Diagnostics
    @Published var diagnosticResults: [DiagnosticResult] {
        didSet { DataStore.shared.save(diagnosticResults, to: "diagnostics.json") }
    }

    // Calendar
    @Published var calendarEvents: [CalendarEvent] {
        didSet { DataStore.shared.save(calendarEvents, to: "calendarEvents.json") }
    }

    // Inventory
    @Published var inventoryItems: [InventoryItem] {
        didSet { DataStore.shared.save(inventoryItems, to: "inventory.json") }
    }

    // Sales & Expenses
    @Published var sales: [SaleRecord] {
        didSet { DataStore.shared.save(sales, to: "sales.json") }
    }
    @Published var expenses: [ExpenseRecord] {
        didSet { DataStore.shared.save(expenses, to: "expenses.json") }
    }

    // Photos
    @Published var farmPhotos: [FarmPhoto] {
        didSet { DataStore.shared.save(farmPhotos, to: "farmPhotos.json") }
    }

    // Learning
    @Published var courses: [Course] {
        didSet { DataStore.shared.save(courses, to: "courses.json") }
    }

    // Settings
    @AppStorage("useMetricUnits") var useMetricUnits = true
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("notifyVaccination") var notifyVaccination = true
    @AppStorage("notifyWatering") var notifyWatering = true
    @AppStorage("notifyEggCollection") var notifyEggCollection = true
    @AppStorage("notifyLowStock") var notifyLowStock = true
    @AppStorage("notifyWeeklyReport") var notifyWeeklyReport = true

    init() {
        let store = DataStore.shared

        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        self.currentUser = store.load(FarmUser.self, from: "currentUser.json") ?? FarmUser()
        self.flocks = store.load([Flock].self, from: "flocks.json") ?? []
        self.eggRecords = store.load([EggRecord].self, from: "eggRecords.json") ?? []
        self.crops = store.load([Crop].self, from: "crops.json") ?? []
        self.diagnosticResults = store.load([DiagnosticResult].self, from: "diagnostics.json") ?? []
        self.calendarEvents = store.load([CalendarEvent].self, from: "calendarEvents.json") ?? []
        self.inventoryItems = store.load([InventoryItem].self, from: "inventory.json") ?? []
        self.sales = store.load([SaleRecord].self, from: "sales.json") ?? []
        self.expenses = store.load([ExpenseRecord].self, from: "expenses.json") ?? []
        self.farmPhotos = store.load([FarmPhoto].self, from: "farmPhotos.json") ?? []
        self.courses = store.load([Course].self, from: "courses.json") ?? SampleCourses.courses
    }

    // MARK: - Auth Actions
    func signIn(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        if currentUser.email == email || currentUser.email.isEmpty {
            if currentUser.email.isEmpty {
                currentUser.email = email
            }
            isAuthenticated = true
            return true
        }
        return false
    }

    func signOut() {
        isAuthenticated = false
    }

    func deleteAccount() {
        // Clear all user data from disk
        let filenames = [
            "currentUser.json", "flocks.json", "eggRecords.json",
            "crops.json", "diagnostics.json", "calendarEvents.json",
            "inventory.json", "sales.json", "expenses.json",
            "farmPhotos.json", "courses.json"
        ]
        for file in filenames {
            DataStore.shared.delete(file)
        }

        // Reset in-memory state
        currentUser = FarmUser()
        flocks = []
        eggRecords = []
        crops = []
        diagnosticResults = []
        calendarEvents = []
        inventoryItems = []
        sales = []
        expenses = []
        farmPhotos = []
        courses = SampleCourses.courses

        // Clear settings
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = false

        // Cancel notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Sign out
        isAuthenticated = false
    }

    func createAccount(user: FarmUser) {
        currentUser = user
        isAuthenticated = true
    }

    // MARK: - Flock Actions
    func addFlock(_ flock: Flock) {
        flocks.append(flock)
    }

    func updateFlock(_ flock: Flock) {
        if let index = flocks.firstIndex(where: { $0.id == flock.id }) {
            flocks[index] = flock
        }
    }

    func deleteFlock(_ flock: Flock) {
        flocks.removeAll { $0.id == flock.id }
        eggRecords.removeAll { $0.flockId == flock.id }
    }

    func addEggRecord(_ record: EggRecord) {
        eggRecords.append(record)
    }

    func deleteEggRecord(_ record: EggRecord) {
        eggRecords.removeAll { $0.id == record.id }
    }

    func eggRecords(for flockId: UUID) -> [EggRecord] {
        eggRecords.filter { $0.flockId == flockId }.sorted { $0.date > $1.date }
    }

    // MARK: - Crop Actions
    func addCrop(_ crop: Crop) {
        crops.append(crop)
    }

    func updateCrop(_ crop: Crop) {
        if let index = crops.firstIndex(where: { $0.id == crop.id }) {
            crops[index] = crop
        }
    }

    func deleteCrop(_ crop: Crop) {
        crops.removeAll { $0.id == crop.id }
    }

    // MARK: - Diagnostic Actions
    func addDiagnosticResult(_ result: DiagnosticResult) {
        diagnosticResults.insert(result, at: 0)
    }

    func deleteDiagnosticResult(_ result: DiagnosticResult) {
        diagnosticResults.removeAll { $0.id == result.id }
    }

    // MARK: - Calendar Actions
    func addEvent(_ event: CalendarEvent) {
        calendarEvents.append(event)
    }

    func updateEvent(_ event: CalendarEvent) {
        if let index = calendarEvents.firstIndex(where: { $0.id == event.id }) {
            calendarEvents[index] = event
        }
    }

    func deleteEvent(_ event: CalendarEvent) {
        calendarEvents.removeAll { $0.id == event.id }
    }

    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return calendarEvents.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    // MARK: - Inventory Actions
    func addInventoryItem(_ item: InventoryItem) {
        inventoryItems.append(item)
    }

    func updateInventoryItem(_ item: InventoryItem) {
        if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
            inventoryItems[index] = item
        }
    }

    func deleteInventoryItem(_ item: InventoryItem) {
        inventoryItems.removeAll { $0.id == item.id }
    }

    // MARK: - Sales Actions
    func addSale(_ sale: SaleRecord) {
        sales.append(sale)
    }

    func deleteSale(_ sale: SaleRecord) {
        sales.removeAll { $0.id == sale.id }
    }

    func addExpense(_ expense: ExpenseRecord) {
        expenses.append(expense)
    }

    func deleteExpense(_ expense: ExpenseRecord) {
        expenses.removeAll { $0.id == expense.id }
    }

    // MARK: - Photo Actions
    func addFarmPhoto(_ photo: FarmPhoto) {
        farmPhotos.insert(photo, at: 0)
    }

    func deleteFarmPhoto(_ photo: FarmPhoto) {
        farmPhotos.removeAll { $0.id == photo.id }
    }

    // MARK: - Learning Actions
    func completeLesson(courseId: UUID, lessonId: UUID) {
        if let courseIndex = courses.firstIndex(where: { $0.id == courseId }),
           let lessonIndex = courses[courseIndex].lessons.firstIndex(where: { $0.id == lessonId }) {
            courses[courseIndex].lessons[lessonIndex].isCompleted = true
            courses[courseIndex].completedLessons = courses[courseIndex].lessons.filter { $0.isCompleted }.count
        }
    }

    // MARK: - Computed Properties
    var totalBirds: Int {
        flocks.reduce(0) { $0 + $1.birdCount }
    }

    var activeCrops: Int {
        crops.count
    }

    var pendingDiagnostics: Int {
        diagnosticResults.filter { $0.status == .warning || $0.status == .alert }.count
    }

    var todayTasks: Int {
        let calendar = Calendar.current
        return calendarEvents.filter { calendar.isDateInToday($0.date) }.count
    }

    var totalRevenue: Double {
        sales.reduce(0) { $0 + $1.total }
    }

    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var netProfit: Double {
        totalRevenue - totalExpenses
    }

    var healthScore: Int {
        var score = 70
        let healthyFlocks = flocks.filter { $0.healthStatus == .healthy }.count
        let totalFlocks = max(flocks.count, 1)
        score += (healthyFlocks * 15 / totalFlocks)

        let healthyCrops = crops.filter { $0.healthStatus == .healthy }.count
        let totalCrops = max(crops.count, 1)
        score += (healthyCrops * 15 / totalCrops)

        return min(score, 100)
    }

    var lowStockItems: [InventoryItem] {
        inventoryItems.filter { $0.isLowStock }
    }

    // MARK: - Smart Tips
    var smartTips: [(icon: String, text: String, learnMoreTopic: String)] {
        var tips: [(String, String, String)] = []

        if flocks.contains(where: { $0.healthStatus == .warning || $0.healthStatus == .alert }) {
            tips.append(("exclamationmark.triangle", "Some flocks need health attention. Check their status and consult a vet if symptoms persist.", "Poultry Care"))
        }

        let totalEggsToday = eggRecords.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.eggsCollected }
        if totalEggsToday == 0 && !flocks.isEmpty {
            tips.append(("oval", "No eggs recorded today. Remember to collect and log egg production daily.", "Egg Quality"))
        }

        if crops.contains(where: { $0.healthStatus != .healthy }) {
            tips.append(("leaf.triangle.badge.exclamationmark", "Some crops show health issues. Early intervention prevents spread.", "Crop Diseases"))
        }

        if !lowStockItems.isEmpty {
            tips.append(("shippingbox", "Low stock alert: \(lowStockItems.map(\.name).joined(separator: ", ")). Restock soon.", "Feed Management"))
        }

        // Default tips
        if tips.isEmpty {
            tips.append(("sun.max", "High temperature may reduce egg production. Consider shading.", "Seasonal Tips"))
            tips.append(("drop", "Add calcium to feed to improve egg shell quality.", "Egg Quality"))
            tips.append(("thermometer", "Check water quality — your flock drinks more in summer.", "Poultry Care"))
        }

        return tips
    }
}
