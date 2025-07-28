
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

                Button("Dark Frame") { captureManager.captureCalibration(.dark, seconds: 3) }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Cattura dark frame")
                Button("Flat Frame") { captureManager.captureCalibration(.flat, seconds: 3) }
                    .accessibilityLabel("Cattura flat frame")
                Button("Bias Frame") { captureManager.captureCalibration(.bias, seconds: 0) }
                    .accessibilityLabel("Cattura bias frame")

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Chiudi") { dismiss() })
        }
    }
}
