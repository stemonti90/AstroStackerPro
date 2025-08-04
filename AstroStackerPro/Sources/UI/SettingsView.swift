
import UIKit
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text(L("repo_cloud"))) {
                if let url = URL(string: "https://github.com/stemonti90/AstroStackerPro") {
                    Link(L("github_repo"), destination: url)
                }
                Toggle(L("sync_icloud"), isOn: .constant(false))
            }
            Section {
                NavigationLink(L("go_pro")) { PaywallView() }
                Button(action: {
                    let url = EngagementManager.shared.referralURL()
                    let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                }) {
                    Text(L("share_referral"))
                }
            }
            Section(header: Text(L("info"))) {
                Text("\(L("version")) 1.0.0")
                Text(L("copyright"))
            }
        }
    }
}
