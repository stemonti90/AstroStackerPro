import SwiftUI
import Foundation
import AVFoundation

/// The main capture interface for AstrostackerPro.  This view adopts the Liquid
/// Glass design language by layering content over blurred, translucent surfaces
/// and providing dynamic feedback on user interactions.
struct CaptureView: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @State private var processedImage: UIImage?
    @State private var useLightPollutionFilter = false
    @State private var showWizard = false
    @State private var showRAWPicker = false

    var body: some View {
        ZStack {
            // Liquid glass backdrop: blurred and tinted based on dynamic lighting.
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Display the processed image or a placeholder.
                    Group {
                        if let ui = processedImage {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(radius: 10, y: 4)
                                .accessibilityLabel(L("process"))
                        } else {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 220)
                                .overlay(Text(L("no_image")).foregroundColor(.secondary))
                        }
                    }

                    // Capture and Process controls on a translucent surface.
                    HStack {
                        Button(captureManager.isRunning ? L("stop") : L("start")) {
                            captureManager.isRunning ? captureManager.stop() : captureManager.start()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .accessibilityLabel(captureManager.isRunning ? L("stop") : L("start"))

                        Button(L("process")) {
                            processedImage = captureManager.processFrames(applyLightPollution: useLightPollutionFilter)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(captureManager.frameCount == 0)
                        .accessibilityLabel(L("process"))
                    }

                    // Calibration and AI options in a glass panel.
                    VStack(spacing: 12) {
                        Toggle(L("light_pollution_filter"), isOn: $useLightPollutionFilter)
                            .disabled(processedImage == nil)
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                            .accessibilityLabel(L("light_pollution_filter"))
                        Toggle(L("ai_denoise"), isOn: $captureManager.applyDenoise)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            .accessibilityLabel(L("ai_denoise"))
                        Slider(value: $captureManager.denoiseStrength, in: 0...1)
                            .disabled(!captureManager.applyDenoise)
                        Toggle(L("super_res"), isOn: $captureManager.applySuperRes)
                            .toggleStyle(SwitchToggleStyle(tint: .pink))
                            .accessibilityLabel(L("super_res"))
                        Toggle(L("derotation"), isOn: $captureManager.applyDerotation)
                            .toggleStyle(SwitchToggleStyle(tint: .yellow))
                            .accessibilityLabel(L("derotation"))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Stacking method picker.
                    Picker(L("stacking"), selection: $captureManager.stackingMethod) {
                        ForEach(StackingMethod.allCases) { Text($0.description).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Exposure, ISO and focus controls.
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(L("iso")): \(Int(captureManager.iso))")
                        Slider(value: $captureManager.iso, in: 50...1600, step: 10)
                        Text(String(format: "\(L("time")): %.4f s", captureManager.exposureDuration))
                        Slider(value: $captureManager.exposureDuration, in: 1/1000...0.1)
                        Text(String(format: "\(L("focus")): %.2f", captureManager.focusPosition))
                        Slider(value: $captureManager.focusPosition, in: 0...1)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Progress indicator and frame count.
                    VStack(spacing: 4) {
                        ProgressView(value: Double(captureManager.frameCount), total: Double(HardwareCapabilities.recommendedMaxFrames))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        Text("\(L("frames")): \(captureManager.frameCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Additional actions.
                    HStack {
                        Button(L("wizard")) { showWizard = true }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                            .accessibilityLabel(L("wizard"))
                            .sheet(isPresented: $showWizard) {
                                CalibrationWizardView().environmentObject(captureManager)
                            }
                        Button(L("take_raw_menu")) { showRAWPicker = true }
                            .buttonStyle(.bordered)
                            .tint(.indigo)
                            .accessibilityLabel(L("take_raw_menu"))
                            .sheet(isPresented: $showRAWPicker) {
                                RAWCaptureSheet().environmentObject(captureManager)
                            }
                    }
                }
                .padding()
            }
        }
    }
}