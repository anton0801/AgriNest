import Foundation

struct InventoryItem: Codable, Identifiable {
    var id: UUID
    var name: String
    var category: InventoryCategory
    var quantity: Double
    var unit: String
    var purchaseDate: Date
    var lowStockThreshold: Double
    var notes: String

    var isLowStock: Bool {
        quantity <= lowStockThreshold
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        category: InventoryCategory = .feed,
        quantity: Double = 0,
        unit: String = "kg",
        purchaseDate: Date = Date(),
        lowStockThreshold: Double = 10,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.purchaseDate = purchaseDate
        self.lowStockThreshold = lowStockThreshold
        self.notes = notes
    }
}

enum InventoryCategory: String, Codable, CaseIterable {
    case feed = "Feed"
    case fertilizers = "Fertilizers"
    case medicines = "Medicines"
    case equipment = "Equipment"

    var icon: String {
        switch self {
        case .feed: return "leaf.circle"
        case .fertilizers: return "drop.circle"
        case .medicines: return "cross.case"
        case .equipment: return "wrench.and.screwdriver"
        }
    }
}
