
import SwiftUI

struct RAWCaptureSheet: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @Environment(\.dismiss) var dismiss
    @State private var capturing = false
    @State private var format: RAWFormat = .raw

    var body: some View {
        NavigationView {
            Form {
                Picker(L("format"), selection: $format) {
                    ForEach(RAWFormat.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                }
                .accessibilityLabel(L("format"))
                Button(capturing ? "In corso…" : L("take_raw")) {
                    capturing = true
                    captureManager.captureRAW(format: format) {
                        capturing = false
                        dismiss()
                    }
                }
                .disabled(capturing)
                .accessibilityLabel(L("take_raw"))
            }
            .navigationTitle(L("raw_title"))
            .navigationBarItems(leading: Button(L("close")) { dismiss() })
        }
    }
}
