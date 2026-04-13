import SwiftUI

@main
struct GreenThumbApp: App {
    @StateObject private var router         = AppRouter()
    @StateObject private var authVM         = AuthViewModel()
    

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                MainTabView()
                    .environmentObject(router)
                    .environmentObject(authVM)
                    
            } else {
                SplashScreenView()
                    .environmentObject(router)
                    .environmentObject(authVM)
                    
            }
        }
    }
}




