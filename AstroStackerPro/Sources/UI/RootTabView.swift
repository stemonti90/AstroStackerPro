
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CaptureView().tabItem { Label(L("tab_capture"), systemImage: "camera.viewfinder") }
            PlannerView().tabItem { Label(L("tab_planner"), systemImage: "calendar") }
            EditorView().tabItem { Label(L("tab_editor"), systemImage: "wand.and.rays") }
            NavigationView { SettingsView() }.tabItem { Label(L("tab_settings"), systemImage: "gear") }
        }
    }
}
