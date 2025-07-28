
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @State private var processedImage: UIImage?
    @State private var useLightPollutionFilter = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let ui = processedImage {
                    Image(uiImage: ui).resizable().scaledToFit()
                } else {
                    Rectangle().fill(Color.black.opacity(0.3))
                        .frame(height: 250)
                        .overlay(Text("Nessuna immagine ancora").foregroundColor(.white))
                }

                HStack {
                    Button(captureManager.isRunning ? "Interrompi" : "Avvia cattura") {
                        captureManager.isRunning ? captureManager.stop() : captureManager.start()
                    }.buttonStyle(.borderedProminent)

                    Button("Elabora") {
                        processedImage = captureManager.processFrames(applyLightPollution: useLightPollutionFilter)
                    }.disabled(captureManager.frameCount == 0)
                }

                Toggle("Filtro antinquinamento luminoso", isOn: $useLightPollutionFilter)
                    .disabled(processedImage == nil)

                Group {
                    Text("ISO: \(Int(captureManager.iso))")
                    Slider(value: $captureManager.iso, in: 50...1600, step: 10)
                    Text(String(format: "Tempo: %.4f s", captureManager.exposureDuration))
                    Slider(value: $captureManager.exposureDuration, in: 1/1000...0.1)
                    Text(String(format: "Focus: %.2f", captureManager.focusPosition))
                    Slider(value: $captureManager.focusPosition, in: 0...1)
                }

                ProgressView(value: Double(captureManager.frameCount), total: 1200)
                    .padding(.vertical, 8)
                Text("Frame: \(captureManager.frameCount)")
                    .font(.caption).foregroundColor(.gray)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
