
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
                        .accessibilityLabel(L("process"))
                } else {
                    Rectangle().fill(Color.secondary.opacity(0.3))
                        .frame(height: 220)
                        .overlay(Text(L("no_image")).foregroundColor(.secondary))
                }

                HStack {
                    Button(captureManager.isRunning ? L("stop") : L("start")) {
                        captureManager.isRunning ? captureManager.stop() : captureManager.start()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(captureManager.isRunning ? L("stop") : L("start"))

                    Button(L("process")) {
                        processedImage = captureManager.processFrames(applyLightPollution: useLightPollutionFilter)
                    }
                    .disabled(captureManager.frameCount == 0)
                    .accessibilityLabel(L("process"))
                }

                Toggle(L("light_pollution_filter"), isOn: $useLightPollutionFilter)
                    .disabled(processedImage == nil)
                    .accessibilityLabel(L("light_pollution_filter"))

                Toggle(L("ai_denoise"), isOn: $captureManager.applyDenoise)
                    .accessibilityLabel(L("ai_denoise"))
                Slider(value: $captureManager.denoiseStrength, in: 0...1)
                    .disabled(!captureManager.applyDenoise)

                Toggle(L("super_res"), isOn: $captureManager.applySuperRes)
                    .accessibilityLabel(L("super_res"))
                Toggle(L("derotation"), isOn: $captureManager.applyDerotation)
                    .accessibilityLabel(L("derotation"))

                Picker(L("stacking"), selection: $captureManager.stackingMethod) {
                    ForEach(StackingMethod.allCases) { Text($0.rawValue.capitalized).tag($0) }
                }.pickerStyle(.segmented)

                Group {
                    Text("\(L("iso")): \(Int(captureManager.iso))")
                    Slider(value: $captureManager.iso, in: 50...1600, step: 10)
                    Text(String(format: "\(L("time")): %.4f s", captureManager.exposureDuration))
                    Slider(value: $captureManager.exposureDuration, in: 1/1000...0.1)
                    Text(String(format: "\(L("focus")): %.2f", captureManager.focusPosition))
                    Slider(value: $captureManager.focusPosition, in: 0...1)
                }

                ProgressView(value: Double(captureManager.frameCount), total: 1200)
                Text("\(L("frames")): \(captureManager.frameCount)").font(.caption).foregroundColor(.gray)

                Button(L("wizard")) { showWizard = true }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(L("wizard"))
                    .sheet(isPresented: $showWizard) { CalibrationWizardView().environmentObject(captureManager) }

                Button(L("take_raw_menu")) { showRAWPicker = true }
                    .accessibilityLabel(L("take_raw_menu"))
                    .sheet(isPresented: $showRAWPicker) { RAWCaptureSheet().environmentObject(captureManager) }
            }
            .padding()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
