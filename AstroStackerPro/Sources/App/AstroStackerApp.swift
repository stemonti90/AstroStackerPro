import SwiftUI

@main
struct AstroStackerProApp: App {
    @StateObject private var services = AppServices()

    var body: some Scene {
        WindowGroup {
            AstroRootView()
                .environmentObject(services)
        }
    }
}

