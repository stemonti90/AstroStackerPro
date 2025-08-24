import UIKit
import SwiftUI

/// The settings view presents repository links, upgrade options and version info on
/// translucent panels consistent with the Liquid Glass aesthetic.
struct SettingsView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Repository & cloud section.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L("repo_cloud")).font(.headline)
                        if let url = URL(string: "https://github.com/stemonti90/AstroStackerPro") {
                            Link(L("github_repo"), destination: url)
                                .foregroundColor(.blue)
                        }
                        Toggle(L("sync_icloud"), isOn: .constant(false))
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Pro & referral section.
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(L("go_pro")) { PaywallView() }
                        Button(action: {
                            let url = EngagementManager.shared.referralURL()
                            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                        }) {
                            Text(L("share_referral"))
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Info section.
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("info")).font(.headline)
                        Text("\(L("version")) 1.0.0")
                        Text(L("copyright"))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Spacer()
                }
                .padding()
            }
        }
    }
}