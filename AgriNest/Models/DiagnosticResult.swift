import Foundation

struct DiagnosticResult: Codable, Identifiable {
    var id: UUID
    var date: Date
    var photoData: Data?
    var diagnosisName: String
    var symptoms: String
    var recommendations: String
    var status: HealthStatus
    var category: DiagnosticCategory

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        photoData: Data? = nil,
        diagnosisName: String = "",
        symptoms: String = "",
        recommendations: String = "",
        status: HealthStatus = .healthy,
        category: DiagnosticCategory = .animal
    ) {
        self.id = id
        self.date = date
        self.photoData = photoData
        self.diagnosisName = diagnosisName
        self.symptoms = symptoms
        self.recommendations = recommendations
        self.status = status
        self.category = category
    }
}

enum DiagnosticCategory: String, Codable, CaseIterable {
    case animal = "Animal"
    case plant = "Plant"
}

// Sample diagnostics for demo mode
struct SampleDiagnostics {
    static let results: [(name: String, symptoms: String, recommendations: String, status: HealthStatus, category: DiagnosticCategory)] = [
        (
            "Vitamin A Deficiency",
            "Pale comb and wattles, reduced egg production, weakness, poor feather condition.",
            "Supplement feed with vitamin A-rich sources such as carrots, leafy greens, or commercial vitamin premix. Ensure balanced nutrition.",
            .warning,
            .animal
        ),
        (
            "Heat Stress in Poultry",
            "Panting, wings spread away from body, reduced feed intake, drop in egg production.",
            "Provide shade and ventilation. Add electrolytes to water. Reduce stocking density. Feed during cooler hours.",
            .alert,
            .animal
        ),
        (
            "Fungal Leaf Disease",
            "Brown or yellow spots on leaves, powdery white coating, leaf curling and drop.",
            "Remove affected leaves. Apply organic fungicide. Improve air circulation. Avoid overhead watering.",
            .warning,
            .plant
        ),
        (
            "Newcastle Disease Signs",
            "Respiratory distress, greenish diarrhea, nervous signs (twisted neck), sudden death.",
            "Isolate affected birds immediately. Contact veterinarian. Vaccinate remaining flock. Disinfect housing.",
            .alert,
            .animal
        ),
        (
            "Healthy Plant",
            "Vibrant green leaves, strong stems, no visible damage or discoloration.",
            "Continue current care routine. Maintain watering schedule. Monitor for any changes.",
            .healthy,
            .plant
        ),
        (
            "Nitrogen Deficiency",
            "Yellowing of lower leaves, stunted growth, light green overall color.",
            "Apply nitrogen-rich fertilizer. Add compost or manure. Consider cover cropping for long-term soil health.",
            .warning,
            .plant
        ),
        (
            "Healthy Poultry",
            "Bright eyes, clean feathers, active behavior, good appetite, normal droppings.",
            "Maintain current feeding and housing conditions. Continue regular health checks.",
            .healthy,
            .animal
        )
    ]

    static func randomResult() -> (name: String, symptoms: String, recommendations: String, status: HealthStatus, category: DiagnosticCategory) {
        results.randomElement()!
    }
}
