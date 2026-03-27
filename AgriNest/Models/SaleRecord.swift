import Foundation

struct SaleRecord: Codable, Identifiable {
    var id: UUID
    var date: Date
    var product: ProductType
    var quantity: Double
    var pricePerUnit: Double
    var notes: String

    var total: Double {
        quantity * pricePerUnit
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        product: ProductType = .eggs,
        quantity: Double = 0,
        pricePerUnit: Double = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.product = product
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.notes = notes
    }
}

enum ProductType: String, Codable, CaseIterable {
    case eggs = "Eggs"
    case vegetables = "Vegetables"
    case poultry = "Poultry"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case other = "Other"

    var icon: String {
        switch self {
        case .eggs: return "oval"
        case .vegetables: return "carrot"
        case .poultry: return "bird"
        case .fruits: return "apple.logo"
        case .dairy: return "cup.and.saucer"
        case .other: return "shippingbox"
        }
    }
}

struct ExpenseRecord: Codable, Identifiable {
    var id: UUID
    var date: Date
    var category: String
    var amount: Double
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        category: String = "Feed",
        amount: Double = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.amount = amount
        self.notes = notes
    }
}
