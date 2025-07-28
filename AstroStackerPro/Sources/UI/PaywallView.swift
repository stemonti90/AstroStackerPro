import SwiftUI

struct PaywallView: View {
    var layout: String { FeatureFlagService.shared.variant("paywall_layout") }
    var body: some View {
        VStack {
            if layout == "B" {
                Text("Pro Features").font(.largeTitle)
            } else {
                Text("Upgrade").font(.title)
            }
            Button("Subscribe") {
                // trigger purchase
            }
            Button("Restore") {
                Task { try? await PurchasesService.shared.restore() }
            }
        }
        .padding()
    }
}
