import Foundation

struct Flock: Codable, Identifiable {
    var id: UUID
    var name: String
    var birdCount: Int
    var birdType: BirdType
    var ageWeeks: Int
    var healthStatus: HealthStatus
    var photoData: Data?
    var feedConsumptionKg: Double
    var mortalityPercent: Double
    var dateAdded: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        birdCount: Int = 0,
        birdType: BirdType = .hens,
        ageWeeks: Int = 0,
        healthStatus: HealthStatus = .healthy,
        photoData: Data? = nil,
        feedConsumptionKg: Double = 0,
        mortalityPercent: Double = 0,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.birdCount = birdCount
        self.birdType = birdType
        self.ageWeeks = ageWeeks
        self.healthStatus = healthStatus
        self.photoData = photoData
        self.feedConsumptionKg = feedConsumptionKg
        self.mortalityPercent = mortalityPercent
        self.dateAdded = dateAdded
    }
}

enum BirdType: String, Codable, CaseIterable {
    case hens = "Hens"
    case broilers = "Broilers"
    case ducks = "Ducks"
    case turkeys = "Turkeys"
}

struct EggRecord: Codable, Identifiable {
    var id: UUID
    var flockId: UUID
    var date: Date
    var eggsCollected: Int
    var brokenEggs: Int
    var soldEggs: Int

    init(
        id: UUID = UUID(),
        flockId: UUID = UUID(),
        date: Date = Date(),
        eggsCollected: Int = 0,
        brokenEggs: Int = 0,
        soldEggs: Int = 0
    ) {
        self.id = id
        self.flockId = flockId
        self.date = date
        self.eggsCollected = eggsCollected
        self.brokenEggs = brokenEggs
        self.soldEggs = soldEggs
    }
}
