import Foundation

struct FarmUser: Codable, Identifiable {
    var id: UUID
    var fullName: String
    var farmName: String
    var country: String
    var email: String
    var farmType: FarmType
    var farmSizeHectares: Double
    var region: String
    var registrationDate: Date

    init(
        id: UUID = UUID(),
        fullName: String = "",
        farmName: String = "",
        country: String = "",
        email: String = "",
        farmType: FarmType = .mixed,
        farmSizeHectares: Double = 0,
        region: String = "",
        registrationDate: Date = Date()
    ) {
        self.id = id
        self.fullName = fullName
        self.farmName = farmName
        self.country = country
        self.email = email
        self.farmType = farmType
        self.farmSizeHectares = farmSizeHectares
        self.region = region
        self.registrationDate = registrationDate
    }
}

enum FarmType: String, Codable, CaseIterable {
    case poultry = "Poultry"
    case vegetables = "Vegetables"
    case mixed = "Mixed Farm"
    case livestock = "Livestock"

    var icon: String {
        switch self {
        case .poultry: return "bird"
        case .vegetables: return "leaf"
        case .mixed: return "square.grid.2x2"
        case .livestock: return "hare"
        }
    }
}

let availableCountries = [
    "United States", "Canada", "United Kingdom", "Australia",
    "India", "Nigeria", "Kenya", "South Africa", "Brazil",
    "Germany", "France", "Netherlands", "Ukraine", "Poland",
    "Mexico", "Colombia", "Argentina", "Philippines", "Thailand",
    "Indonesia", "Vietnam", "Egypt", "Tanzania", "Ethiopia"
].sorted()
