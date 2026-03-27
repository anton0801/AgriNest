import Foundation
import SwiftUI

struct CalendarEvent: Codable, Identifiable {
    var id: UUID
    var title: String
    var date: Date
    var eventType: EventType
    var notes: String

    init(
        id: UUID = UUID(),
        title: String = "",
        date: Date = Date(),
        eventType: EventType = .custom,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.eventType = eventType
        self.notes = notes
    }
}

enum EventType: String, Codable, CaseIterable {
    case vaccination = "Vaccination"
    case eggCollection = "Egg Collection"
    case planting = "Planting"
    case harvest = "Harvest"
    case vetCheckup = "Vet Checkup"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .vaccination: return "syringe"
        case .eggCollection: return "oval"
        case .planting: return "leaf"
        case .harvest: return "basket"
        case .vetCheckup: return "stethoscope"
        case .custom: return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .vaccination: return Color(hex: "E8B89D")
        case .eggCollection: return Color(hex: "7BAE7F")
        case .planting: return Color(hex: "6B9E5E")
        case .harvest: return Color(hex: "D9A68B")
        case .vetCheckup: return Color(hex: "DC5050")
        case .custom: return .white
        }
    }
}
