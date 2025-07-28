
import SwiftUI
@main struct AstroStackerApp: App {
    @StateObject private var captureManager = AstroCaptureManager()
    @StateObject private var planner = PlannerViewModel()
    @StateObject private var editorVM = EditorViewModel()
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(captureManager)
                .environmentObject(planner)
                .environmentObject(editorVM)
        }
    }
}
