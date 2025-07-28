
import SwiftUI
struct CalibrationWizardView: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Procedura calibrazione").font(.title2).bold()
                Text("Cattura Dark, Flat e Bias frame per migliorare il risultato.")
                    .multilineTextAlignment(.center)
                Button("Cattura Dark Frame") { captureManager.startDarkFrameCapture(seconds: 3) }
                    .buttonStyle(.borderedProminent)
                Button("Cattura Flat Frame") { captureManager.startFlatFrameCapture(seconds: 3) }
                Button("Cattura Bias Frame") { captureManager.startBiasFrameCapture(count: 20) }
                Spacer()
            }.padding()
             .navigationBarItems(leading: Button("Chiudi") { dismiss() })
        }
    }
}
