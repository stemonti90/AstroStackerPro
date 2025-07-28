
import SwiftUI

struct RAWCaptureSheet: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @Environment(\.dismiss) var dismiss
    @State private var capturing = false
    @State private var format: RAWFormat = .raw

    var body: some View {
        NavigationView {
            Form {
                Picker("Formato", selection: $format) {
                    ForEach(RAWFormat.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                }
                .accessibilityLabel("Seleziona formato RAW")
                Button(capturing ? "In corso…" : "Scatta RAW") {
                    capturing = true
                    captureManager.captureRAW(format: format) {
                        capturing = false
                        dismiss()
                    }
                }
                .disabled(capturing)
                .accessibilityLabel("Scatta RAW")
            }
            .navigationTitle("RAW/ProRAW")
            .navigationBarItems(leading: Button("Chiudi") { dismiss() })
        }
    }
}
