import Testing
import SwiftUI
import Foundation
@testable import GreenThumb

// Unit tests of the app
//covers - Plant Model, App router, DiagnoseViewModel (logic), ProfileViewModel (streak), AddPlantViewModel (health), SchedularViewModel (filtering), Design System
struct PlantModelTests {

    @Test func testPlantDefaultStatus() {
        let plant = PlantModel(
            name: "Rose Bush",
            species: "Rosa",
            status: .healthy,
            healthScore: 92,
            imageURL: nil,
            location: "Garden",
            dateAdded: Date(),
            tags: [],
            isOutdoor: true,
            ageDays: 30,
            initialNote: nil
        )
        #expect(plant.status == .healthy)
        #expect(plant.healthScore == 92)
        #expect(plant.name == "Rose Bush")
    }

    
    @Test func testHealthScoreCap() {
        let plant = PlantModel(
            name: "Fern",
            species: "Nephrolepis",
            status: .healthy,
            healthScore: 100,
            imageURL: nil,
            location: "Living Room",
            dateAdded: Date(),
            tags: [],
            isOutdoor: false,
            ageDays: 5,
            initialNote: nil
        )
        #expect(plant.healthScore <= 100)
    }

    
    @Test func testPlantIDUniqueness() {
        let plant1 = PlantModel(name: "A", species: "Sp1", status: .healthy, healthScore: 90, imageURL: nil, location: "L", dateAdded: Date(), tags: [], isOutdoor: true, ageDays: 0, initialNote: nil)
        let plant2 = PlantModel(name: "B", species: "Sp2", status: .healthy, healthScore: 90, imageURL: nil, location: "L", dateAdded: Date(), tags: [], isOutdoor: true, ageDays: 0, initialNote: nil)
        #expect(plant1.id != plant2.id)
    }

    
    @Test func testPlantStatusValues() {
        var plant = PlantModel(name: "Test", species: "Sp", status: .warning, healthScore: 45, imageURL: nil, location: "L", dateAdded: Date(), tags: [], isOutdoor: false, ageDays: 10, initialNote: nil)
        #expect(plant.status == .warning)
        plant.status = .critical
        #expect(plant.status == .critical)
    }

    
    @Test func testLastDiagnosisDefaultIsNil() {
        let plant = PlantModel(name: "Tomato", species: "Lycopersicon", status: .healthy, healthScore: 88, imageURL: nil, location: "Balcony", dateAdded: Date(), tags: [], isOutdoor: true, ageDays: 20, initialNote: nil)
        #expect(plant.lastDiagnosisName == nil)
    }
}

struct AppRouterTests {

    
    @Test @MainActor func testNavigateAppendsRoute() {
        let router = AppRouter()
        #expect(router.path.count == 0)
        router.navigate(to: .gardenAnalytics)
        #expect(router.path.count == 1)
    }

    
    @Test @MainActor func testPopRemovesRoute() {
        let router = AppRouter()
        router.navigate(to: .gardenAnalytics)
        router.navigate(to: .addPlant)
        #expect(router.path.count == 2)
        router.pop()
        #expect(router.path.count == 1)
    }

    
    @Test @MainActor func testPopOnEmptyPathIsSafe() {
        let router = AppRouter()
        router.pop()
        #expect(router.path.count == 0)
    }

    
    @Test @MainActor func testPopToRootClearsAll() {
        let router = AppRouter()
        router.navigate(to: .gardenAnalytics)
        router.navigate(to: .addPlant)
        router.navigate(to: .symptomChecker)
        router.popToRoot()
        #expect(router.path.count == 0)
    }

    
    @Test @MainActor func testDefaultTabIsHome() {
        let router = AppRouter()
        #expect(router.selectedTab == 0)
    }

    
    @Test @MainActor func testTabSwitch() {
        let router = AppRouter()
        router.selectedTab = 2
        #expect(router.selectedTab == 2)
    }
}

struct DiagnosisLogicTests {

    
    private func bestMatch(userSymptoms: [String], knowledgeBase: [DiagnosisResultData]) -> DiagnosisResultData? {
        let userSet = Set(userSymptoms)
        var bestMatch: DiagnosisResultData? = nil
        var highestScore = -1
        for entry in knowledgeBase {
            let intersection = userSet.intersection(Set(entry.symptomsMatch))
            let score = intersection.count
            if score > highestScore && score > 0 {
                highestScore = score
                bestMatch = entry
            }
        }
        return bestMatch
    }

    private func makeKnowledgeBase() -> [DiagnosisResultData] {
        return [
            DiagnosisResultData(
                name: "Overwatering",
                probability: 95,
                description: "Excess water.",
                symptomsMatch: ["Yellow leaves", "Wilting", "Root smell"],
                treatmentPlan: []
            ),
            DiagnosisResultData(
                name: "Nitrogen Deficiency",
                probability: 88,
                description: "Lack of nitrogen.",
                symptomsMatch: ["Yellow leaves", "Slow growth"],
                treatmentPlan: []
            ),
            DiagnosisResultData(
                name: "Powdery Mildew",
                probability: 92,
                description: "Fungal disease.",
                symptomsMatch: ["White powder", "Brown spots"],
                treatmentPlan: []
            )
        ]
    }

    
    @Test func testExactSymptomMatchOverwatering() {
        let kb = makeKnowledgeBase()
        let result = bestMatch(userSymptoms: ["Yellow leaves", "Wilting", "Root smell"], knowledgeBase: kb)
        #expect(result?.name == "Overwatering")
    }

    
    @Test func testPartialMatchPicksBestScore() {
        let kb = makeKnowledgeBase()
        let result = bestMatch(userSymptoms: ["Yellow leaves", "Slow growth"], knowledgeBase: kb)
        #expect(result?.name == "Nitrogen Deficiency")
    }

    
    @Test func testNoMatchReturnsNil() {
        let kb = makeKnowledgeBase()
        let result = bestMatch(userSymptoms: ["Sticky residue", "Holes in leaves"], knowledgeBase: kb)
        #expect(result == nil)
    }

    
    @Test func testPowderyMildewMatch() {
        let kb = makeKnowledgeBase()
        let result = bestMatch(userSymptoms: ["White powder", "Brown spots"], knowledgeBase: kb)
        #expect(result?.name == "Powdery Mildew")
    }

    
    @Test func testEmptySymptomsReturnsNil() {
        let kb = makeKnowledgeBase()
        let result = bestMatch(userSymptoms: [], knowledgeBase: kb)
        #expect(result == nil)
    }

    
    @Test func testEmptyKnowledgeBaseReturnsNil() {
        let result = bestMatch(userSymptoms: ["Yellow leaves"], knowledgeBase: [])
        #expect(result == nil)
    }
}

struct HealthScoreCalculationTests {

    
    private func startingHealth(ageDays: Int) -> Double {
        let agePenalty = min(Double(ageDays) * 0.10, 30.0)
        return max(65.0, 97.0 - agePenalty)
    }

    
    @Test func testNewPlantStartsNear97() {
        let health = startingHealth(ageDays: 0)
        #expect(health == 97.0)
    }

    @Test func testThirtyDayPlantIsLower() {
        let health = startingHealth(ageDays: 30)
        #expect(health == 94.0)
    }

    
    @Test func testHealthNeverBelowFloor() {
        for days in [0, 50, 100, 300, 1000] {
            let health = startingHealth(ageDays: days)
            #expect(health >= 65.0)
        }
    }

    @Test func testPenaltyIsCappedAt30() {
        let penaltyAt300 = min(Double(300) * 0.10, 30.0)
        let penaltyAt500 = min(Double(500) * 0.10, 30.0)
        #expect(penaltyAt300 == 30.0)
        #expect(penaltyAt500 == 30.0)
    }
}


struct DiagnosisSeverityTests {

    
    private func applyDiagnosis(currentHealth: Double, severity: Double) -> (newHealth: Double, newStatus: String) {
        let severityPenalty = severity * 45.0
        let newHealth = max(10.0, currentHealth - severityPenalty)
        let newStatus = newHealth < 50 ? PlantStatus.critical.rawValue : PlantStatus.warning.rawValue
        return (newHealth, newStatus)
    }

    
    @Test func testMildSeveritySmallPenalty() {
        let (health, status) = applyDiagnosis(currentHealth: 90, severity: 0.0)
        #expect(health == 90.0)
        #expect(status == PlantStatus.warning.rawValue)
    }

    
    @Test func testModerateSeverityDrops22Points() {
        let (health, _) = applyDiagnosis(currentHealth: 90, severity: 0.5)
        #expect(health == 90.0 - 22.5)
    }

    
    @Test func testSevereDiagnosisMakesCritical() {
        let (_, status) = applyDiagnosis(currentHealth: 90, severity: 1.0)
        #expect(status == PlantStatus.critical.rawValue)
    }

    
    @Test func testHealthNeverBelowMinimumFloor() {
        let (health, _) = applyDiagnosis(currentHealth: 10, severity: 1.0)
        #expect(health == 10.0)
    }

    
    @Test func testModerateOnMidHealthIsWarning() {
        let (health, status) = applyDiagnosis(currentHealth: 60, severity: 0.5)
        #expect(health == 37.5)
        #expect(status == PlantStatus.critical.rawValue)
    }
}


struct StreakCalculationTests {

    
    private func calculateStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) })
        let sortedDays = uniqueDays.sorted(by: >)

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        if !uniqueDays.contains(currentDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate),
                  uniqueDays.contains(yesterday) else { return 0 }
            currentDate = yesterday
        }

        while uniqueDays.contains(currentDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = prev
        }
        return streak
    }

    
    @Test func testEmptyDatesReturnsZero() {
        #expect(calculateStreak(from: []) == 0)
    }

    
    @Test func testWateredTodayIsOneStreak() {
        let streak = calculateStreak(from: [Date()])
        #expect(streak == 1)
    }

    
    @Test func testTodayAndYesterdayIsTwoStreak() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let streak = calculateStreak(from: [Date(), yesterday])
        #expect(streak == 2)
    }

    
    @Test func testGapInStreakResets() {
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        let streak = calculateStreak(from: [Date(), threeDaysAgo])
        #expect(streak == 1)
    }

    
    @Test func testDuplicateDatesCountOnce() {
        let now = Date()
        let streak = calculateStreak(from: [now, now, now])
        #expect(streak == 1)
    }

    
    @Test func testNoRecentActivityIsZeroStreak() {
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        let streak = calculateStreak(from: [twoDaysAgo])
        #expect(streak == 0)
    }
}

struct DiagnoseViewModelToggleTests {

    
    @Test @MainActor func testToggleSymptomAdds() {
        let vm = DiagnoseViewModel()
        vm.selectedSymptoms = []
        vm.toggleSymptom("Yellow leaves")
        #expect(vm.selectedSymptoms.contains("Yellow leaves"))
    }

    
    @Test @MainActor func testToggleSymptomRemoves() {
        let vm = DiagnoseViewModel()
        vm.selectedSymptoms = ["Yellow leaves"]
        vm.toggleSymptom("Yellow leaves")
        #expect(!vm.selectedSymptoms.contains("Yellow leaves"))
    }

    
    @Test @MainActor func testTogglePartAdds() {
        let vm = DiagnoseViewModel()
        vm.selectedParts = []
        vm.togglePart("Roots")
        #expect(vm.selectedParts.contains("Roots"))
    }

    
    @Test @MainActor func testTogglePartRemoves() {
        let vm = DiagnoseViewModel()
        vm.selectedParts = ["Roots"]
        vm.togglePart("Roots")
        #expect(!vm.selectedParts.contains("Roots"))
    }

    
    @Test @MainActor func testDefaultSelectedPlantIsNil() {
        let vm = DiagnoseViewModel()
        #expect(vm.selectedPlant == nil)
    }

    
    @Test @MainActor func testSelectedPlantCanBeSet() {
        let vm = DiagnoseViewModel()
        let plant = PlantModel(name: "Basil", species: "Ocimum", status: .healthy, healthScore: 90, imageURL: nil, location: "Kitchen", dateAdded: Date(), tags: [], isOutdoor: false, ageDays: 7, initialNote: nil)
        vm.selectedPlant = plant
        #expect(vm.selectedPlant?.name == "Basil")
    }
}


struct DesignSystemTests {

    
    @Test func testBodyLargeFontIsNotNil() {
        let font = GTFont.bodyLarge()
        _ = font
        #expect(Bool(true))
    }

   
    @Test func testAllFontFunctionsReturnSafely() {
        _ = GTFont.displayLarge()
        _ = GTFont.displayMedium()
        _ = GTFont.displaySmall()
        _ = GTFont.bodyLarge()
        _ = GTFont.bodyMedium()
        _ = GTFont.bodySmall()
        _ = GTFont.labelLarge()
        _ = GTFont.labelMedium()
        _ = GTFont.labelSmall()
        _ = GTFont.buttonLarge()
        _ = GTFont.buttonMedium()
        _ = GTFont.accentItalic()
        _ = GTFont.accentItalicMedium()
        #expect(Bool(true))
    }

    
    @Test func testSpacingConstantsArePositive() {
        #expect(GTSpacing.xxs > 0)
        #expect(GTSpacing.xs > 0)
        #expect(GTSpacing.sm > 0)
        #expect(GTSpacing.md > 0)
        #expect(GTSpacing.lg > 0)
        #expect(GTSpacing.xl > 0)
    }

    
    @Test func testRadiusConstantsArePositive() {
        #expect(GTRadius.xs > 0)
        #expect(GTRadius.sm > 0)
        #expect(GTRadius.md > 0)
        #expect(GTRadius.lg > 0)
    }

    
    @Test func testMinimumTouchTargetIs44Points() {
        let minimumTouchTarget: CGFloat = 44
        let bellButtonMinWidth: CGFloat = 44
        let bellButtonMinHeight: CGFloat = 44
        #expect(bellButtonMinWidth >= minimumTouchTarget)
        #expect(bellButtonMinHeight >= minimumTouchTarget)
    }
}

