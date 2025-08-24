import SwiftUI

struct AstroRootView: View {
    @EnvironmentObject var services: AppServices

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel
    }

    var body: some View {
        TabView {
            NavigationStack { CaptureScreen() }
                .tabItem { Label("Cattura", systemImage: "camera.fill") }

            NavigationStack { EditorScreen() }
                .tabItem { Label("Editor", systemImage: "wand.and.stars") }

            NavigationStack { SettingsScreen() }
                .tabItem { Label("Impostazioni", systemImage: "gearshape") }
        }
        .tint(ASPTheme.accent)
        .background(ASPTheme.bg)
    }
}

