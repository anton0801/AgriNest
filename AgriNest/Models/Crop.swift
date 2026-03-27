import Foundation

struct Crop: Codable, Identifiable {
    var id: UUID
    var name: String
    var growthStage: GrowthStage
    var nextWateringDate: Date
    var healthStatus: HealthStatus
    var harvestForecast: String
    var plantedDate: Date
    var notes: String

    init(
        id: UUID = UUID(),
        name: String = "",
        growthStage: GrowthStage = .seedling,
        nextWateringDate: Date = Date(),
        healthStatus: HealthStatus = .healthy,
        harvestForecast: String = "",
        plantedDate: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.growthStage = growthStage
        self.nextWateringDate = nextWateringDate
        self.healthStatus = healthStatus
        self.harvestForecast = harvestForecast
        self.plantedDate = plantedDate
        self.notes = notes
    }
}

enum GrowthStage: String, Codable, CaseIterable {
    case seedling = "Seedling"
    case vegetative = "Vegetative"
    case flowering = "Flowering"
    case harvest = "Harvest"

    var icon: String {
        switch self {
        case .seedling: return "leaf"
        case .vegetative: return "leaf.fill"
        case .flowering: return "camera.macro"
        case .harvest: return "basket"
        }
    }

    var progress: Double {
        switch self {
        case .seedling: return 0.25
        case .vegetative: return 0.5
        case .flowering: return 0.75
        case .harvest: return 1.0
        }
    }
}
