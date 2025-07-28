
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Repo & Cloud")) {
                if let url = URL(string: "https://github.com/stemonti90/AstroStackerPro") {
                    Link("GitHub Repo", destination: url)
                }
                Toggle("Sync iCloud", isOn: .constant(false))
            }
            Section(header: Text("Info")) {
                Text("Versione 1.0.0")
                Text("© 2025 AstroStackerPro")
            }
        }
    }
}
