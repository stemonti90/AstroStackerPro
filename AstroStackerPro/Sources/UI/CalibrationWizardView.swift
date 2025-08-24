//
//  CalibrationWizardView.swift
//  AstroStackerPro
//

import SwiftUI

struct CalibrationWizardView: View {
    @EnvironmentObject var services: AppServices
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Procedura calibrazione")
                    .font(.title2).bold()
                Text("Cattura Dark, Flat e Bias frame per migliorare il risultato.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Button("Dark Frame") {
                        startCalibration(.dark, frames: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Cattura dark frame")

                    Button("Flat Frame") {
                        startCalibration(.flat, frames: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Cattura flat frame")

                    Button("Bias Frame") {
                        startCalibration(.bias, frames: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Cattura bias frame")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Calibrazione")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    // MARK: - Placeholder funzionante
    private func startCalibration(_ type: CalibrationType, frames: Int) {
        // In questa build usiamo la cattura normale con N frame.
        // Quando avrai la pipeline dark/flat/bias, sostituisci qui.
        services.capture.frames = frames
        services.capture.start()
        print("▶️ Calibrazione \(type.rawValue) avviata con \(frames) frame")
        dismiss()
    }

    private enum CalibrationType: String {
        case dark = "Dark"
        case flat = "Flat"
        case bias = "Bias"
    }
}

