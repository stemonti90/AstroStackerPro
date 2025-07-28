
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CaptureView().tabItem { Label("Cattura", systemImage: "camera.viewfinder") }
            PlannerView().tabItem { Label("Pianifica", systemImage: "calendar") }
            EditorView().tabItem { Label("Editor", systemImage: "wand.and.rays") }
            SettingsView().tabItem { Label("Impostazioni", systemImage: "gear") }
        }
    }
}
