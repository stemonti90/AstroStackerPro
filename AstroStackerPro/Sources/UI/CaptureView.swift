
import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @State private var processedImage: UIImage?
    @State private var useLightPollutionFilter = false
    @State private var showWizard = false
    @State private var showRAWPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let ui = processedImage {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Immagine elaborata")
                } else {
                    Rectangle().fill(Color.black.opacity(0.3))
                        .frame(height: 220)
                        .overlay(Text("Nessuna immagine").foregroundColor(.white))
                }

                HStack {
                    Button(captureManager.isRunning ? "Stop" : "Start") {
                        captureManager.isRunning ? captureManager.stop() : captureManager.start()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(captureManager.isRunning ? "Ferma acquisizione" : "Avvia acquisizione")

                    Button("Elabora") {
                        processedImage = captureManager.processFrames(applyLightPollution: useLightPollutionFilter)
                    }
                    .disabled(captureManager.frameCount == 0)
                    .accessibilityLabel("Elabora frames")
                }

                Toggle("Filtro antinquinamento", isOn: $useLightPollutionFilter)
                    .disabled(processedImage == nil)
                    .accessibilityLabel("Filtro antinquinamento luminoso")

                Toggle("AI Denoise", isOn: $captureManager.applyDenoise)
                    .accessibilityLabel("Attiva AI Denoise")
                Slider(value: $captureManager.denoiseStrength, in: 0...1)
                    .disabled(!captureManager.applyDenoise)

                Toggle("Super-Resolution 2x", isOn: $captureManager.applySuperRes)
                    .accessibilityLabel("Abilita super risoluzione 2x")
                Toggle("Derotation", isOn: $captureManager.applyDerotation)
                    .accessibilityLabel("Abilita derotazione")

                Picker("Stacking", selection: $captureManager.stackingMethod) {
                    ForEach(StackingMethod.allCases) { Text($0.rawValue.capitalized).tag($0) }
                }.pickerStyle(.segmented)

                Group {
                    Text("ISO: \(Int(captureManager.iso))")
                    Slider(value: $captureManager.iso, in: 50...1600, step: 10)
                    Text(String(format: "Tempo: %.4f s", captureManager.exposureDuration))
                    Slider(value: $captureManager.exposureDuration, in: 1/1000...0.1)
                    Text(String(format: "Fuoco: %.2f", captureManager.focusPosition))
                    Slider(value: $captureManager.focusPosition, in: 0...1)
                }

                ProgressView(value: Double(captureManager.frameCount), total: 1200)
                Text("Frame: \(captureManager.frameCount)").font(.caption).foregroundColor(.gray)

                Button("Wizard Calibrazione") { showWizard = true }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Apri wizard calibrazione")
                    .sheet(isPresented: $showWizard) { CalibrationWizardView().environmentObject(captureManager) }

                Button("Scatta RAW/ProRAW") { showRAWPicker = true }
                    .accessibilityLabel("Scatta RAW o ProRAW")
                    .sheet(isPresented: $showRAWPicker) { RAWCaptureSheet().environmentObject(captureManager) }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
