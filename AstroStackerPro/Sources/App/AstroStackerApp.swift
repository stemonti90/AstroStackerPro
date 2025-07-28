
import SwiftUI
import FirebaseCore
#if ENABLE_CRASHLYTICS
import FirebaseCrashlytics
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MetricKitManager.shared.register()
        return true
    }
}

@main
struct AstroStackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
