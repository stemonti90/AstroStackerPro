
import SwiftUI
struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Repo & Cloud")) {
                Link("GitHub Repo", destination: URL(string: "https://github.com/stemonti90/AstroStackerPro")!)
                Toggle("Sync iCloud", isOn: .constant(false))
            }
            Section(header: Text("Info")) {
                Text("Versione 1.0.0")
                Text("© 2025 AstroStackerPro")
            }
        }
    }
}
