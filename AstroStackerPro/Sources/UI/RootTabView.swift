import SwiftUI

/// The root tab view hosts the four main sections of the app: capture, planner,
/// editor and settings.  It uses the system accent colour and ignores safe area
/// insets to fully embrace the Liquid Glass aesthetic.
struct RootTabView: View {
    var body: some View {
        TabView {
            CaptureView()
                .tabItem {
                    Label(L("tab_capture"), systemImage: "camera.viewfinder")
                }
            PlannerView()
                .tabItem {
                    Label(L("tab_planner"), systemImage: "calendar")
                }
            EditorView()
                .tabItem {
                    Label(L("tab_editor"), systemImage: "wand.and.rays")
                }
            NavigationView { SettingsView() }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label(L("tab_settings"), systemImage: "gear")
                }
        }
        .accentColor(.primary)
        .ignoresSafeArea()
    }
}