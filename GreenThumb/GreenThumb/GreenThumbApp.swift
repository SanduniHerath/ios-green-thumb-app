import SwiftUI

@main
struct green_thumb_appApp: App {
    @StateObject private var router         = AppRouter()
    

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


