import Foundation

struct FarmPhoto: Codable, Identifiable {
    var id: UUID
    var imageData: Data?
    var category: PhotoCategory
    var note: String
    var date: Date

    init(
        id: UUID = UUID(),
        imageData: Data? = nil,
        category: PhotoCategory = .animals,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.imageData = imageData
        self.category = category
        self.note = note
        self.date = date
    }
}

enum PhotoCategory: String, Codable, CaseIterable {
    case animals = "Animals"
    case crops = "Crops"
    case equipment = "Equipment"
    case problems = "Problems"

    var icon: String {
        switch self {
        case .animals: return "hare"
        case .crops: return "leaf"
        case .equipment: return "wrench.and.screwdriver"
        case .problems: return "exclamationmark.triangle"
        }
    }
}
