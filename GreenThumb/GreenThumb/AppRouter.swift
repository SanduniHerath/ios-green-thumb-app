import SwiftUI
import Combine

//this is the all navigation handle file
enum AppRoute: Hashable {
    //auth
    case onboarding1
    case onboarding2
    case signIn
    case signUp
    case otpVerification
    case register
    case gardenAnalytics

    //main
    case main

    //garden
    case plantDetails(PlantModel)
    case addPlant
    case growthTimeline(PlantModel)
    case addObservation(PlantModel)
    case smartScheduler(plantId: String? = nil)

   //diagnose
    case symptomChecker
    case diagnosisResult
    case careGuide(String)
    case fertiliserGuide

    //expert
    case expertProfile(ExpertModel)
    case bookSession(ExpertModel)
    case expertChat(ExpertModel)
    case nearbyExperts

    //community
    case communityPost(CommunityPostModel)

    //profile
    case appSettings
    case notifications
}

extension PlantModel: Hashable {
    static func == (lhs: PlantModel, rhs: PlantModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension ExpertModel: Hashable {
    static func == (lhs: ExpertModel, rhs: ExpertModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension CommunityPostModel: Hashable {
    static func == (lhs: CommunityPostModel, rhs: CommunityPostModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

//Router
@MainActor
class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var showMain: Bool = false
    @Published var selectedTab: Int = 0

    func navigate(to route: AppRoute) { path.append(route) }
    func pop()               { if !path.isEmpty { path.removeLast() } }
    func popToRoot()         { path = NavigationPath() }
    func goToMain()          { showMain = true }
}
