
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
                    Image(uiImage: ui).resizable().scaledToFit()
                } else {
                    Rectangle().fill(Color.black.opacity(0.3))
                        .frame(height: 220)
                        .overlay(Text("Nessuna immagine").foregroundColor(.white))
                }

                HStack {
                    Button(captureManager.isRunning ? "Stop" : "Start") {
                        captureManager.isRunning ? captureManager.stop() : captureManager.start()
                    }.buttonStyle(.borderedProminent)

                    Button("Elabora") {
                        processedImage = captureManager.processFrames(applyLightPollution: useLightPollutionFilter)
                    }.disabled(captureManager.frameCount == 0)
                }

                Toggle("Filtro antinquinamento", isOn: $useLightPollutionFilter)
                    .disabled(processedImage == nil)

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
                    .sheet(isPresented: $showWizard) { CalibrationWizardView().environmentObject(captureManager) }

                Button("Scatta RAW/ProRAW") { showRAWPicker = true }
                    .sheet(isPresented: $showRAWPicker) { RAWCaptureSheet().environmentObject(captureManager) }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
