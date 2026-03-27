import Foundation

struct Course: Codable, Identifiable {
    var id: UUID
    var name: String
    var icon: String
    var lessonsCount: Int
    var completedLessons: Int
    var lessons: [Lesson]

    var progress: Double {
        guard lessonsCount > 0 else { return 0 }
        return Double(completedLessons) / Double(lessonsCount)
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        icon: String = "book",
        lessonsCount: Int = 0,
        completedLessons: Int = 0,
        lessons: [Lesson] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.lessonsCount = lessonsCount
        self.completedLessons = completedLessons
        self.lessons = lessons
    }
}

struct Lesson: Codable, Identifiable {
    var id: UUID
    var title: String
    var content: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String = "", content: String = "", isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.isCompleted = isCompleted
    }
}

struct KnowledgeCard: Codable, Identifiable {
    var id: UUID
    var title: String
    var explanation: String
    var practicalTip: String
    var icon: String

    init(id: UUID = UUID(), title: String = "", explanation: String = "", practicalTip: String = "", icon: String = "lightbulb") {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.practicalTip = practicalTip
        self.icon = icon
    }
}

struct QuizQuestion: Codable, Identifiable {
    var id: UUID
    var question: String
    var options: [String]
    var correctIndex: Int
    var explanation: String

    init(id: UUID = UUID(), question: String = "", options: [String] = [], correctIndex: Int = 0, explanation: String = "") {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
    }
}

// MARK: - Sample Data
struct SampleCourses {
    static let courses: [Course] = [
        Course(
            name: "Poultry Care",
            icon: "bird",
            lessonsCount: 5,
            completedLessons: 0,
            lessons: [
                Lesson(title: "Housing & Space Requirements", content: "Proper poultry housing requires 2-3 sq ft per bird inside the coop and 8-10 sq ft in the run. Ensure adequate ventilation without drafts. The coop should protect from predators and weather. Install roosts at 2-4 feet height with 8-10 inches per bird."),
                Lesson(title: "Feeding Basics", content: "Layer hens need 16-18% protein feed. Broilers require 20-24% protein starter feed. Always provide clean fresh water. Supplement with calcium (oyster shell) for layers. Feed consumption averages 1/4 pound per bird per day."),
                Lesson(title: "Common Diseases", content: "Watch for Newcastle disease, Marek's disease, and coccidiosis. Signs include lethargy, reduced feed intake, abnormal droppings, and respiratory issues. Vaccinate on schedule and maintain biosecurity. Quarantine new birds for 30 days."),
                Lesson(title: "Egg Collection & Storage", content: "Collect eggs at least twice daily. Store at 45-55°F with 70% humidity. Do not wash eggs unless necessary—washing removes the protective bloom. Refrigerated eggs last 4-5 weeks. Mark each egg with collection date."),
                Lesson(title: "Seasonal Management", content: "In winter, provide supplemental lighting (14-16 hours total) to maintain production. In summer, ensure shade and ventilation. Adjust feed quantity seasonally. Monitor water consumption—birds drink more in heat.")
            ]
        ),
        Course(
            name: "Crop Diseases",
            icon: "leaf.triangle.badge.exclamationmark",
            lessonsCount: 4,
            completedLessons: 0,
            lessons: [
                Lesson(title: "Identifying Fungal Diseases", content: "Fungal diseases show as spots, powdery coatings, or mold on leaves. Common types include powdery mildew, downy mildew, and rust. Prevention includes proper spacing, air circulation, and avoiding overhead watering."),
                Lesson(title: "Bacterial Infections", content: "Bacterial diseases cause wilting, soft rot, and leaf spots with yellow halos. Spread through water splash, insects, and contaminated tools. Remove infected plants promptly. Use copper-based sprays as prevention."),
                Lesson(title: "Viral Plant Diseases", content: "Viruses cause mottled leaves, stunted growth, and deformed fruit. Spread mainly by insects (aphids, whiteflies). No cure exists—remove infected plants. Control insect vectors and use resistant varieties."),
                Lesson(title: "Nutrient Deficiency vs Disease", content: "Learn to distinguish nutrient deficiency from disease. Nitrogen deficiency: yellowing from bottom up. Phosphorus: purple tint. Potassium: brown leaf edges. Iron: yellowing between veins on new growth.")
            ]
        ),
        Course(
            name: "Egg Quality",
            icon: "oval",
            lessonsCount: 3,
            completedLessons: 0,
            lessons: [
                Lesson(title: "Shell Quality Factors", content: "Shell quality depends on calcium intake, vitamin D3, and hen age. Provide oyster shell free-choice. Older hens lay larger eggs with thinner shells. Stress and heat reduce shell quality."),
                Lesson(title: "Internal Quality", content: "Fresh eggs have thick, firm whites and centered yolks. Quality decreases with age and storage temperature. The chalazae (white cords) indicate freshness. Blood spots are safe but reduce market appeal."),
                Lesson(title: "Grading & Market Standards", content: "Grade AA: firm whites, high yolks. Grade A: reasonably firm. Grade B: thinner whites. Clean shells required for market. Size categories: Jumbo (>70g), XL (64g), L (57g), M (50g).")
            ]
        ),
        Course(
            name: "Feed Management",
            icon: "scalemass",
            lessonsCount: 4,
            completedLessons: 0,
            lessons: [
                Lesson(title: "Feed Types & Formulation", content: "Starter (0-6 weeks): 20-24% protein. Grower (6-20 weeks): 15-18% protein. Layer (20+ weeks): 16-18% protein with 3.5-4% calcium. Broiler finisher: 18-20% protein. Always match feed to bird age and purpose."),
                Lesson(title: "Feed Storage", content: "Store feed in cool, dry locations in sealed containers. Protect from rodents and moisture. Moldy feed can be toxic—never use it. Buy feed in quantities you'll use within 2-3 weeks for freshness."),
                Lesson(title: "Water Management", content: "Clean water is the most important nutrient. Birds drink 2x their feed weight in water daily. More in hot weather. Clean waterers daily. Test water quality annually. Add electrolytes during heat stress."),
                Lesson(title: "Cost Optimization", content: "Track feed conversion ratio (FCR). For layers, aim for 2.0-2.5 kg feed per kg eggs. For broilers, target 1.6-2.0 FCR. Buy feed in bulk when possible. Consider mixing your own feed to reduce costs.")
            ]
        ),
        Course(
            name: "Seasonal Tips",
            icon: "sun.and.horizon",
            lessonsCount: 4,
            completedLessons: 0,
            lessons: [
                Lesson(title: "Spring Preparations", content: "Clean and disinfect coops after winter. Start new seedlings indoors. Prepare soil with compost. Plan crop rotation. Order chicks for spring delivery. Check fencing and equipment."),
                Lesson(title: "Summer Management", content: "Focus on heat management for animals. Irrigate crops consistently. Watch for pest pressure increase. Harvest regularly to encourage production. Preserve excess through canning or freezing."),
                Lesson(title: "Fall Harvest & Prep", content: "Harvest remaining crops before frost. Plant cover crops. Prepare housing for winter—add insulation, check heaters. Cull non-productive birds. Stock up on feed and supplies."),
                Lesson(title: "Winter Care", content: "Maintain warmth without sealing ventilation. Provide supplemental lighting. Use heated waterers. Feed extra calories for body heat. Plan next year's crops and order seeds early.")
            ]
        )
    ]

    static let knowledgeCards: [KnowledgeCard] = [
        KnowledgeCard(
            title: "Why Hens Stop Laying Eggs",
            explanation: "Hens may stop laying due to several factors: insufficient daylight (less than 14 hours), stress from predators or changes, molting season, poor nutrition, extreme temperatures, or aging. Most hens are most productive in their first 2 years.",
            practicalTip: "Add supplemental lighting in winter to maintain 14-16 hours of total light. Ensure consistent, high-quality layer feed with adequate calcium.",
            icon: "questionmark.circle"
        ),
        KnowledgeCard(
            title: "Signs of Unhealthy Feathers",
            explanation: "Healthy feathers are smooth, shiny, and lie flat. Warning signs include: bald patches (parasites or pecking), broken feathers (stress or overcrowding), discolored feathers (nutritional deficiency), and pin feathers outside molt season.",
            practicalTip: "Check birds regularly during handling. Dust baths help prevent external parasites. Ensure adequate protein in diet (16-18% for layers).",
            icon: "exclamationmark.triangle"
        ),
        KnowledgeCard(
            title: "Best Feed Ratios for Broilers",
            explanation: "Broilers need different feed at each stage: Starter (0-2 weeks) at 23% protein, Grower (2-4 weeks) at 20% protein, and Finisher (4-8 weeks) at 18% protein. Feed conversion improves with proper nutrition and management.",
            practicalTip: "Always provide fresh, clean water. Feed should be available 24/7 for broilers. Track weight weekly to ensure proper growth rate.",
            icon: "scalemass"
        ),
        KnowledgeCard(
            title: "How to Prevent Newcastle Disease",
            explanation: "Newcastle disease is a highly contagious viral disease in poultry. It spreads through direct contact, contaminated equipment, and wild birds. Symptoms include respiratory distress, nervous signs, and sudden death.",
            practicalTip: "Vaccinate all birds on schedule. Maintain strict biosecurity—change shoes/clothes before entering coops. Quarantine new birds for 30 days.",
            icon: "shield.checkered"
        ),
        KnowledgeCard(
            title: "Optimal Soil pH for Vegetables",
            explanation: "Most vegetables grow best in slightly acidic soil (pH 6.0-7.0). Tomatoes prefer 6.0-6.8, potatoes 5.0-6.0, and brassicas 6.5-7.5. Soil pH affects nutrient availability—too high or too low locks out essential minerals.",
            practicalTip: "Test soil pH every spring. Add lime to raise pH or sulfur to lower it. Adjust gradually—no more than 0.5 pH units per season.",
            icon: "drop.triangle"
        ),
        KnowledgeCard(
            title: "Water-Saving Irrigation Tips",
            explanation: "Drip irrigation uses 30-50% less water than sprinklers. Mulching reduces evaporation by up to 70%. Water early morning to minimize evaporation. Group plants by water needs for efficient irrigation.",
            practicalTip: "Install a simple drip system with a timer. Apply 2-4 inches of organic mulch around plants. Monitor soil moisture before watering.",
            icon: "drop"
        )
    ]

    static let quizQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "What temperature is ideal for newly hatched chicks?",
            options: ["20–25°C", "32–35°C", "40–45°C", "15–20°C"],
            correctIndex: 1,
            explanation: "Newly hatched chicks need 32–35°C (90–95°F) in their first week. Reduce temperature by 3°C each week until reaching ambient temperature."
        ),
        QuizQuestion(
            question: "How many hours of light do laying hens need for optimal production?",
            options: ["8–10 hours", "10–12 hours", "14–16 hours", "18–20 hours"],
            correctIndex: 2,
            explanation: "Laying hens need 14–16 hours of total light (natural + supplemental) for optimal egg production."
        ),
        QuizQuestion(
            question: "What protein percentage should layer feed contain?",
            options: ["10–12%", "16–18%", "24–26%", "30–32%"],
            correctIndex: 1,
            explanation: "Layer feed should contain 16–18% protein along with 3.5–4% calcium for strong egg shells."
        ),
        QuizQuestion(
            question: "Which nutrient deficiency causes yellowing of lower leaves?",
            options: ["Potassium", "Iron", "Nitrogen", "Calcium"],
            correctIndex: 2,
            explanation: "Nitrogen deficiency causes yellowing starting from the oldest (lowest) leaves first, as the plant moves nitrogen to newer growth."
        ),
        QuizQuestion(
            question: "What is a normal feed conversion ratio for broilers?",
            options: ["0.5–1.0", "1.6–2.0", "3.0–4.0", "5.0–6.0"],
            correctIndex: 1,
            explanation: "A good FCR for broilers is 1.6–2.0, meaning 1.6–2.0 kg of feed produces 1 kg of body weight."
        ),
        QuizQuestion(
            question: "How long should new birds be quarantined before joining the flock?",
            options: ["3 days", "1 week", "30 days", "No quarantine needed"],
            correctIndex: 2,
            explanation: "New birds should be quarantined for at least 30 days to observe for disease symptoms before introducing them to your existing flock."
        ),
        QuizQuestion(
            question: "What soil pH is best for most vegetables?",
            options: ["4.0–5.0", "6.0–7.0", "7.5–8.5", "8.5–9.5"],
            correctIndex: 1,
            explanation: "Most vegetables thrive in slightly acidic soil with pH 6.0–7.0. This range allows optimal nutrient absorption."
        ),
        QuizQuestion(
            question: "At what age do hens typically start laying eggs?",
            options: ["4–6 weeks", "8–12 weeks", "18–22 weeks", "30–36 weeks"],
            correctIndex: 2,
            explanation: "Most hens begin laying at 18–22 weeks (4.5–5.5 months). Production peaks around 25–30 weeks of age."
        )
    ]
}
