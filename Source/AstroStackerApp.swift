
import SwiftUI

@main
struct AstroStackerApp: App {
    @StateObject private var captureManager = AstroCaptureManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(captureManager)
        }
    }
}
